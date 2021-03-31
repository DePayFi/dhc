# frozen_string_literal: true

require 'rails_helper'

describe DHC::Caching do
  before(:each) do
    DHC.config.interceptors = [DHC::Caching]
    DHC::Caching.cache = Rails.cache
    Rails.cache.clear
  end

  let!(:first_request) do
    stub_request(:get, "http://depay.fi/").to_return(body: 'Website')
  end

  let!(:second_request) do
    stub_request(:get, "http://depay.fi/weather").to_return(body: 'The weather')
  end

  it 'does not fetch requests served from cache when doing requests in parallel with hydra' do
    DHC.request([{ url: 'http://depay.fi', cache: true }, { url: 'http://depay.fi/weather', cache: true }])
    DHC.request([{ url: 'http://depay.fi', cache: true }, { url: 'http://depay.fi/weather', cache: true }])
    assert_requested first_request, times: 1
    assert_requested second_request, times: 1
  end
end
