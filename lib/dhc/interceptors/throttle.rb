# frozen_string_literal: true

require 'active_support/duration'

class DHC::Throttle < DHC::Interceptor
  class OutOfQuota < StandardError
  end

  CACHE_KEY = 'DHC/throttle/tracker/v1'

  class << self

    def tracker(provider)
      (Rails.cache.read(CACHE_KEY) || {})[provider] || {}
    end

    def tracker=(track)
      Rails.cache.write(CACHE_KEY, (Rails.cache.read(CACHE_KEY) || {}).merge({ track[:provider] => track }))
    end
  end

  def before_request
    return unless options
    break! if break?
  end

  def after_response
    return unless track?
    self.class.tracker = {
      provider: options.dig(:provider),
      limit: limit,
      remaining: remaining,
      expires: expires
    }
  end

  private

  def options
    @options ||= request.options.dig(:throttle) || {}
  end

  def provider
    @provider ||= request.options.dig(:throttle, :provider)
  end

  def track?
    (options.dig(:remaining) && [options.dig(:track), response.headers].none?(&:blank?) ||
      options.dig(:track).present?
    )
  end

  def break?
    @do_break ||= begin
      return if options.dig(:break) && !options.dig(:break).match('%')
      tracker = self.class.tracker(options[:provider])
      return if tracker.blank? || tracker[:remaining].blank? || tracker[:limit].blank? || tracker[:expires].blank?
      return if Time.zone.now > tracker[:expires]
      remaining = tracker[:remaining] * 100
      limit = tracker[:limit]
      remaining_quota = 100 - options[:break].to_i
      remaining <= remaining_quota * limit
    end
  end

  def break!
    raise(OutOfQuota, "Reached predefined quota for #{provider}")
  end

  def limit
    @limit ||=
      if options.dig(:limit).is_a?(Proc)
        options.dig(:limit).call(response)
      elsif options.dig(:limit).is_a?(Integer)
        options.dig(:limit)
      elsif options.dig(:limit).is_a?(Hash) && options.dig(:limit, :header) && response.headers
        response.headers[options.dig(:limit, :header)]&.to_i
      end
  end

  def remaining
    @remaining ||= begin
      if options.dig(:remaining).is_a?(Proc)
        options.dig(:remaining).call(response)
      elsif options.dig(:remaining).is_a?(Hash) && options.dig(:remaining, :header) && response.headers
        response.headers[options.dig(:remaining, :header)]&.to_i
      elsif options.dig(:remaining).blank?
        remaining_before = self.class.tracker(provider).dig(:remaining) || request.options.dig(:throttle, :limit)
        expires = self.class.tracker(provider).dig(:expires)
        if expires && expires > DateTime.now
          remaining_before - 1
        else
          request.options.dig(:throttle, :limit) - 1
        end
      end
    end
  end

  def expires
    @expires ||= begin
      if options.dig(:expires).is_a?(ActiveSupport::Duration) && self.class.tracker(provider).dig(:expires).present?
        if self.class.tracker(provider)[:expires] > DateTime.now
          self.class.tracker(provider)[:expires]
        else
          DateTime.now + options.dig(:expires)
        end
      elsif options.dig(:expires).is_a?(Hash) && options.dig(:expires, :header)

        convert_expire_value(response.headers[options.dig(:expires, :header)]) if response.headers
      else
        convert_expire_value(options.dig(:expires))
      end
    end
  end

  def convert_expire_value(value)
    return if value.blank?
    return value.call(response) if value.is_a?(Proc)
    return DateTime.now + value if value.is_a?(ActiveSupport::Duration)
    return Time.parse(value) if value.match(/GMT/)
    Time.zone.at(value.to_i).to_datetime
  end
end
