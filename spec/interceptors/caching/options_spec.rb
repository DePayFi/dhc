# frozen_string_literal: true

require 'rails_helper'

# due to the fact that options passed into DHC get dup'ed
# we need a class where we can setup method expectations
# with `expect_any_instance`
class CacheMock
  def fetch(*_); end

  def write(*_); end
end

describe DHC::Caching do
  let(:default_cache) { DHC::Caching.cache }

  before(:each) do
    stub_request(:get, 'http://depay.fi').to_return(status: 200, body: 'The Website')
    DHC.config.interceptors = [DHC::Caching]
    default_cache.clear
  end

  it 'does cache' do
    expect(default_cache).to receive(:fetch)
    expect(default_cache).to receive(:write)
    DHC.get('http://depay.fi', cache: true)
  end

  it 'does not cache' do
    expect(default_cache).not_to receive(:fetch)
    expect(default_cache).not_to receive(:write)
    DHC.get('http://depay.fi')
  end

  context 'options - directly via DHC.get' do
    it 'uses the default cache' do
      expect(default_cache).to receive(:fetch)
      expect(default_cache).to receive(:write)
      DHC.get('http://depay.fi', cache: true)
    end

    it 'uses the provided cache' do
      expect_any_instance_of(CacheMock).to receive(:fetch)
      expect_any_instance_of(CacheMock).to receive(:write)
      DHC.get('http://depay.fi', cache: { use: CacheMock.new })
    end

    it 'cache options are properly forwarded to the cache' do
      cache_options = { expires_in: 5.minutes, race_condition_ttl: 15.seconds }
      expect(default_cache).to receive(:write).with(anything, anything, cache_options)
      DHC.get('http://depay.fi', cache: cache_options)
    end
  end

  context 'options - via endpoint configuration' do
    it 'uses the default cache' do
      DHC.config.endpoint(:local, 'http://depay.fi', cache: true)
      expect(default_cache).to receive(:fetch)
      expect(default_cache).to receive(:write)
      DHC.get(:local)
    end

    it 'uses the provided cache' do
      options = { cache: { use: CacheMock.new } }
      DHC.config.endpoint(:local, 'http://depay.fi', options)
      expect_any_instance_of(CacheMock).to receive(:fetch)
      expect_any_instance_of(CacheMock).to receive(:write)
      DHC.get(:local)
    end

    it 'cache options are properly forwarded to the cache' do
      cache_options = { expires_in: 5.minutes, race_condition_ttl: 15.seconds }
      DHC.config.endpoint(:local, 'http://depay.fi', cache: cache_options)
      expect(default_cache).to receive(:write).with(anything, anything, cache_options)
      DHC.get(:local)
    end
  end
end
