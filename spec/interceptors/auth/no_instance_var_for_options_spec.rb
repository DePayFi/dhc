# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  before(:each) do
    class AuthPrepInterceptor < DHC::Interceptor

      def before_request
        request.options[:auth] = { bearer: 'sometoken' }
      end
    end

    DHC.config.interceptors = [AuthPrepInterceptor, DHC::Auth]
  end

  after do
    DHC.config.reset
  end

  it 'does not use instance variables internally so that other interceptors can still change auth options' do
    stub_request(:get, "http://depay.fi/")
      .with(headers: { 'Authorization' => 'Bearer sometoken' })
      .to_return(status: 200)
    DHC.get('http://depay.fi')
  end
end
