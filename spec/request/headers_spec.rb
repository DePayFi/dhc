# frozen_string_literal: true

require 'rails_helper'

describe DHC::Request do
  it 'provides request headers' do
    stub_request(:get, 'http://depay.fi')
    response = DHC.get('http://depay.fi')
    request = response.request
    expect(request.headers.keys).to include 'User-Agent'
  end
end
