# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  before(:each) do
    DHC.config.interceptors = [DHC::Auth]
  end

  it 'adds basic auth in a correct way even if username and password are especially long' do
    options = { basic: { username: '123456789101234', password: '12345678901234567890123456789012' } }
    DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
    stub_request(:get, 'http://depay.fi')
      .with(headers: { 'Authorization' => 'Basic MTIzNDU2Nzg5MTAxMjM0OjEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEy' })
    DHC.get(:local)
  end
end
