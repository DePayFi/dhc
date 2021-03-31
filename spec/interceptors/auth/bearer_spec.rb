# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  before(:each) do
    DHC.config.interceptors = [DHC::Auth]
  end

  it 'adds the bearer token to every request' do
    def bearer_token
      '123456'
    end
    options = { bearer: -> { bearer_token } }
    DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
    stub_request(:get, 'http://depay.fi').with(headers: { 'Authorization' => 'Bearer 123456' })
    DHC.get(:local)
  end
end
