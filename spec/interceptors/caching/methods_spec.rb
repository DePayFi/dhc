# frozen_string_literal: true

require 'rails_helper'

describe DHC::Caching do
  before(:each) do
    DHC.config.interceptors = [DHC::Caching]
    DHC::Caching.cache = Rails.cache
    Rails.cache.clear

    DHC.config.endpoint(:local, 'http://depay.fi', cache: { expires_in: 5.minutes })
  end

  let!(:stub) { stub_request(:post, 'http://depay.fi').to_return(status: 200, body: 'The Website') }

  it 'only caches GET requests by default' do
    expect(Rails.cache).not_to receive(:write)
    DHC.post(:local)
    assert_requested stub, times: 1
  end

  it 'also caches other methods, when explicitly enabled' do
    expect(Rails.cache).to receive(:write)
      .with(
        "DHC_CACHE(v#{DHC::Caching::CACHE_VERSION}): POST http://depay.fi",
        {
          body: 'The Website',
          code: 200,
          headers: nil,
          return_code: nil,
          mock: :webmock
        }, { expires_in: 5.minutes }
      )
      .and_call_original
    original_response = DHC.post(:local, cache: { methods: [:post] })
    cached_response = DHC.post(:local, cache: { methods: [:post] })
    expect(original_response.body).to eq cached_response.body
    expect(original_response.code).to eq cached_response.code
    expect(original_response.headers).to eq cached_response.headers
    assert_requested stub, times: 1
  end
end
