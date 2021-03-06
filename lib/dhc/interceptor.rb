# frozen_string_literal: true

class DHC::Interceptor

  attr_reader :request

  def initialize(request)
    @request = request
  end

  def response
    @request.response
  end

  def before_init; end

  def before_request; end

  def after_request; end

  def before_response; end

  def after_response; end

  # Prevent Interceptors from beeing duplicated!
  # Their classes have flag-character.
  # When duplicated you can't check for their class name anymore:
  # e.g. options.deep_dup[:interceptors].include?(DHC::Caching) # false
  def self.dup
    self
  end

  def all_interceptor_classes
    @all_interceptors ||= DHC::Interceptors.new(request).all.map(&:class)
  end
end
