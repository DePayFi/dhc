# frozen_string_literal: true

require 'rails_helper'
require 'prometheus/client'

describe DHC::Prometheus do
  before(:each) do
    DHC.config.interceptors = [DHC::Prometheus]
    DHC::Prometheus.client = Prometheus::Client
    DHC::Prometheus.namespace = 'test_app'
    stub_request(:get, 'http://depay.fi')
    expect(Prometheus::Client).to receive(:registry).and_call_original.at_least(:once)
  end

  let(:client) { double("prometheus/client") }

  context 'registering' do
    it 'creates a counter and histogram registry in the prometheus client' do
      expect(Prometheus::Client.registry).to receive(:counter).and_call_original.once
        .with(:dhc_requests, 'Counter of all DHC requests.')
      expect(Prometheus::Client.registry).to receive(:histogram).and_call_original.once
        .with(:dhc_request_seconds, 'Request timings for all DHC requests in seconds.')

      DHC.get('http://depay.fi')
      DHC.get('http://depay.fi') # second request, registration should happen only once
    end
  end

  context 'logging' do
    let(:requests_registry_double) { double('requests_registry_double') }
    let(:times_registry_double) { double('times_registry_double') }

    it 'logs monitoring information to the created registries' do
      expect(Prometheus::Client.registry).to receive(:get).and_return(requests_registry_double).once
        .with(:dhc_requests)
      expect(Prometheus::Client.registry).to receive(:get).and_return(times_registry_double).once
        .with(:dhc_request_seconds)

      expect(requests_registry_double).to receive(:increment).once
        .with(
          code: 200,
          success: true,
          timeout: false,
          app: 'test_app',
          host: 'depay.fi'
        )

      expect(times_registry_double).to receive(:observe).once
        .with({ host: 'depay.fi', app: 'test_app' }, 0)

      DHC.get('http://depay.fi')
    end
  end
end
