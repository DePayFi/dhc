# frozen_string_literal: true

require 'rails_helper'

describe DHC::Monitoring do
  let(:stub) { stub_request(:get, 'http://depay.fi').to_return(status: 200, body: 'The Website') }
  let(:endpoint_configuration) { DHC.config.endpoint(:local, 'http://depay.fi') }

  module Statsd
    def self.count(_path, _value); end

    def self.timing(_path, _value); end
  end

  before(:each) do
    DHC.config.interceptors = [DHC::Monitoring]
    DHC::Monitoring.statsd = Statsd
    Rails.cache.clear
    endpoint_configuration
  end

  it 'does not report anything if no statsd is configured' do
    stub
    DHC.get(:local) # and also does not crash ;)
  end

  context 'statsd configured' do
    it 'reports trial, response and timing by default ' do
      stub
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.before_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.after_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.count', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.200', 1)
      expect(Statsd).to receive(:timing).with('dhc.dummy.test.depay_fi.get.time', anything)
      DHC.get(:local)
    end

    it 'does not report timing when response failed' do
      stub_request(:get, 'http://depay.fi').to_return(status: 500)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.before_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.after_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.count', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.500', 1)
      expect(Statsd).not_to receive(:timing)
      expect { DHC.get(:local) }.to raise_error DHC::ServerError
    end

    it 'reports timeout instead of status code if response timed out' do
      stub_request(:get, 'http://depay.fi').to_timeout
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.before_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.after_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.count', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.timeout', 1)
      expect(Statsd).not_to receive(:timing)
      expect { DHC.get(:local) }.to raise_error DHC::Timeout
    end

    it 'allows to set the stats key for request' do
      stub
      expect(Statsd).to receive(:count).with('defined_key.before_request', 1)
      expect(Statsd).to receive(:count).with('defined_key.after_request', 1)
      expect(Statsd).to receive(:count).with('defined_key.count', 1)
      expect(Statsd).to receive(:count).with('defined_key.200', 1)
      expect(Statsd).to receive(:timing).with('defined_key.time', anything)
      DHC.get(:local, monitoring_key: 'defined_key')
    end
  end

  context 'without protocol' do
    let(:endpoint_configuration) { DHC.config.endpoint(:local, 'depay.fi') }

    it 'reports trial, response and timing by default ' do
      stub
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.before_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.after_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.count', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.200', 1)
      expect(Statsd).to receive(:timing).with('dhc.dummy.test.depay_fi.get.time', anything)
      DHC.get(:local)
    end
  end

  context 'with configured environment' do
    before do
      DHC::Monitoring.env = 'beta'
    end

    it 'uses the configured env' do
      stub
      expect(Statsd).to receive(:count).with('dhc.dummy.beta.depay_fi.get.before_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.beta.depay_fi.get.after_request', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.beta.depay_fi.get.count', 1)
      expect(Statsd).to receive(:count).with('dhc.dummy.beta.depay_fi.get.200', 1)
      DHC.get(:local)
    end
  end
end
