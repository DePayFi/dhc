# frozen_string_literal: true

class DHC::Monitoring < DHC::Interceptor

  # Options forwarded to the monitoring
  FORWARDED_OPTIONS = {
    monitoring_key: :key
  }

  include ActiveSupport::Configurable

  config_accessor :statsd, :env

  def before_request
    return unless statsd
    DHC::Monitoring.statsd.count("#{key}.before_request", 1)
  end

  def after_request
    return unless statsd
    DHC::Monitoring.statsd.count("#{key}.count", 1)
    DHC::Monitoring.statsd.count("#{key}.after_request", 1)
  end

  def after_response
    return unless statsd
    monitor_time!
    monitor_cache!
    monitor_response!
  end

  private

  def monitor_time!
    DHC::Monitoring.statsd.timing("#{key}.time", response.time) if response.success?
  end

  def monitor_cache!
    return if request.options[:cache].blank?
    return unless monitor_caching_configuration_check
    if response.from_cache?
      DHC::Monitoring.statsd.count("#{key}.cache.hit", 1)
    else
      DHC::Monitoring.statsd.count("#{key}.cache.miss", 1)
    end
  end

  def monitor_caching_configuration_check
    return true if all_interceptor_classes.include?(DHC::Caching) && all_interceptor_classes.index(self.class) > all_interceptor_classes.index(DHC::Caching)
    warn("[WARNING] Your interceptors must include DHC::Caching and DHC::Monitoring and also in that order.")
  end

  def monitor_response!
    if response.timeout?
      DHC::Monitoring.statsd.count("#{key}.timeout", 1)
    else
      DHC::Monitoring.statsd.count("#{key}.#{response.code}", 1)
    end
  end

  def key
    key = options(request.options)[:key]
    return key if key.present?

    url = sanitize_url(request.url)
    key = [
      'dhc',
      module_parent_name.underscore,
      DHC::Monitoring.env || Rails.env,
      URI.parse(url).host.gsub(/\./, '_'),
      request.method
    ]
    key.join('.')
  end

  def module_parent_name
    (ActiveSupport.gem_version >= Gem::Version.new('6.0.0')) ? Rails.application.class.module_parent_name : Rails.application.class.parent_name
  end

  def sanitize_url(url)
    return url if url.match(%r{https?://})
    "http://#{url}"
  end

  def options(input = {})
    options = {}
    FORWARDED_OPTIONS.each do |k, v|
      options[v] = input[k] if input.key?(k)
    end
    options
  end
end
