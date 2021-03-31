# frozen_string_literal: true

require 'rails_helper'

describe DHC::Monitoring do
  let(:stub) do
    stub_request(:get, 'http://depay.fi').to_return(status: 200, body: 'The Website')
  end

  module Statsd
    def self.count(_path, _value); end

    def self.timing(_path, _value); end
  end

  before(:each) do
    DHC::Monitoring.statsd = Statsd
    Rails.cache.clear
    allow(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.before_request', 1)
    allow(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.count', 1)
    allow(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.after_request', 1)
    allow(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.200', 1)
  end

  context 'interceptors configured correctly' do
    before do
      DHC.config.interceptors = [DHC::Caching, DHC::Monitoring]
    end

    context 'requesting with cache option' do
      it 'monitors miss/hit for caching' do
        stub
        expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.cache.miss', 1)
        expect(Statsd).to receive(:count).with('dhc.dummy.test.depay_fi.get.cache.hit', 1)
        DHC.get('http://depay.fi', cache: true)
        DHC.get('http://depay.fi', cache: true)
      end
    end

    context 'request uncached' do
      it 'requesting without cache option' do
        stub
        expect(Statsd).not_to receive(:count).with('dhc.dummy.test.depay_fi.get.cache.miss', 1)
        expect(Statsd).not_to receive(:count).with('dhc.dummy.test.depay_fi.get.cache.hit', 1)
        DHC.get('http://depay.fi')
        DHC.get('http://depay.fi')
      end
    end
  end

  context 'wrong interceptor order' do
    before(:each) do
      DHC.config.interceptors = [DHC::Monitoring, DHC::Caching] # monitoring needs to be after Caching
    end

    it 'does monitors miss/hit for caching and warns about wrong order of interceptors' do
      stub
      expect(Statsd).not_to receive(:count).with('dhc.dummy.test.depay_fi.get.cache.miss', 1)
      expect(Statsd).not_to receive(:count).with('dhc.dummy.test.depay_fi.get.cache.hit', 1)
      expect(-> {
        DHC.get('http://depay.fi', cache: true)
        DHC.get('http://depay.fi', cache: true)
      }).to output("[WARNING] Your interceptors must include DHC::Caching and DHC::Monitoring and also in that order.\n[WARNING] Your interceptors must include DHC::Caching and DHC::Monitoring and also in that order.\n").to_stderr
    end
  end
end
