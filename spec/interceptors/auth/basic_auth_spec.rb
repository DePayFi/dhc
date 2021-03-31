# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  before(:each) do
    DHC.config.interceptors = [DHC::Auth]
  end

  it 'adds basic auth to every request' do
    options = { basic: { username: 'steve', password: 'can' } }
    DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
    stub_request(:get, 'http://depay.fi')
      .with(headers: { 'Authorization' => 'Basic c3RldmU6Y2Fu' })
    DHC.get(:local)
  end
end
