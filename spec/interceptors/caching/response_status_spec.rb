# frozen_string_literal: true

require 'rails_helper'

describe DHC::Caching do
  before(:each) do
    DHC.config.interceptors = [DHC::Caching]
    DHC.config.endpoint(:local, 'http://depay.fi', cache: true)
    Rails.cache.clear
    # leverage the Typhoeus internal mock attribute in order to get Typhoeus evaluate the return_code
    # lib/typhoeus/response/status.rb:48
    allow_any_instance_of(Typhoeus::Response).to receive(:mock).and_return(false)
  end

  let!(:stub) { stub_request(:get, 'http://depay.fi').to_return(status: 200, body: 'The Website') }

  it 'provides the correct response status for responses from cache' do
    stub
    # the real request provides the return_code
    allow_any_instance_of(Typhoeus::Response).to receive(:options)
      .and_return(code: 200, status_message: '', body: 'The Website', headers: nil, return_code: :ok)
    response = DHC.get(:local)
    expect(response.success?).to eq true
    # the cached response should get it from the cache
    allow_any_instance_of(Typhoeus::Response).to receive(:options).and_call_original
    cached_response = DHC.get(:local)
    expect(cached_response.success?).to eq true
  end
end
