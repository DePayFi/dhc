# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  context 'simple bearer token authentication' do
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

  context 'refresh' do
    before(:each) do
      DHC.config.interceptors = [DHC::Auth, DHC::Retry]
    end

    let(:first_access_token) { '1_ACCESS_TOKEN' }
    let(:second_access_token) { '2_ACCESS_TOKEN' }
    let(:third_access_token) { '3_ACCESS_TOKEN' }

    let :session do
      {
        access_token: first_access_token
      }
    end

    refresh = -> {}

    before do
      refresh = ->(response = nil) {
        if response
          if response.code == 401 && response.data && response.data['error_code'] == 'ACCESS_TOKEN_EXPIRED'
            session[:access_token] = third_access_token
          end
        else
          session[:access_token] = second_access_token
        end
      }
    end

    it 'refreshes the bearer if it expired' do
      stub_request(:get, 'http://depay.fi/').with(headers: { 'Authorization' => 'Bearer 2_ACCESS_TOKEN' })
      DHC.get('http://depay.fi', auth: { bearer: -> { session[:access_token] }, refresh: refresh, expires_at: -> { (DateTime.now - 1.minute).to_s } })
    end

    it 'can evaluate response errors (like unauthorized) inside the refresh proc' do
      stub_request(:get, 'http://depay.fi/').with(headers: { 'Authorization' => 'Bearer 2_ACCESS_TOKEN' })
        .to_return(status: 401, body: { "error_code": 'ACCESS_TOKEN_EXPIRED' }.to_json)
      stub_request(:get, 'http://depay.fi/').with(headers: { 'Authorization' => 'Bearer 3_ACCESS_TOKEN' })
      DHC.get('http://depay.fi', auth: { bearer: -> { session[:access_token] }, refresh: refresh, expires_at: -> { (DateTime.now - 1.minute).to_s } })
    end
  end
end
