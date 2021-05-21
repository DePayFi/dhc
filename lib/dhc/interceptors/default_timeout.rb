# frozen_string_literal: true

class DHC::DefaultTimeout < DHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :timeout, :connecttimeout

  CONNECTTIMEOUT = 2 # seconds
  TIMEOUT = 15 # seconds

  def before_init
    request_options = (request.options || {})
    request_options[:timeout] ||= timeout || TIMEOUT
    request_options[:connecttimeout] ||= connecttimeout || CONNECTTIMEOUT
  end
end
