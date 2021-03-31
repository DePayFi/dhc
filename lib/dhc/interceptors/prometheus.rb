# frozen_string_literal: true

class DHC::Prometheus < DHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :client, :namespace

  REQUEST_COUNTER_KEY = :dhc_requests
  REQUEST_HISTOGRAM_KEY = :dhc_request_seconds

  class << self
    attr_accessor :registered
  end

  def initialize(request)
    super(request)
    return if DHC::Prometheus.registered || DHC::Prometheus.client.blank?

    begin
      DHC::Prometheus.client.registry.counter(DHC::Prometheus::REQUEST_COUNTER_KEY, 'Counter of all DHC requests.')
      DHC::Prometheus.client.registry.histogram(DHC::Prometheus::REQUEST_HISTOGRAM_KEY, 'Request timings for all DHC requests in seconds.')
    rescue Prometheus::Client::Registry::AlreadyRegisteredError => e
      Rails.logger.error(e) if defined?(Rails)
    ensure
      DHC::Prometheus.registered = true
    end
  end

  def after_response
    return if !DHC::Prometheus.registered || DHC::Prometheus.client.blank?

    host = URI.parse(request.url).host

    DHC::Prometheus.client.registry
      .get(DHC::Prometheus::REQUEST_COUNTER_KEY)
      .increment(
        code: response.code,
        success: response.success?,
        timeout: response.timeout?,
        host: host,
        app: DHC::Prometheus.namespace
      )

    DHC::Prometheus.client.registry
      .get(DHC::Prometheus::REQUEST_HISTOGRAM_KEY)
      .observe({
                 host: host,
                 app: DHC::Prometheus.namespace
               }, response.time)
  end
end
