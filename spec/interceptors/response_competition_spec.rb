# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'interceptor response competition' do
    before(:each) do
      class LocalCacheInterceptor < DHC::Interceptor
        @@cached = false
        cattr_accessor :cached

        def before_request
          if @@cached
            return DHC::Response.new(Typhoeus::Response.new(response_code: 200, return_code: :ok, response_body: 'Im served from local cache'), nil)
          end
        end
      end

      class RemoteCacheInterceptor < DHC::Interceptor

        def before_request
          if request.response.nil?
            return DHC::Response.new(Typhoeus::Response.new(response_code: 200, return_code: :ok, response_body: 'Im served from remote cache'), nil)
          end
        end
      end

      DHC.configure { |c| c.interceptors = [LocalCacheInterceptor, RemoteCacheInterceptor] }
    end

    it 'can handle multiple interceptors that compete for returning the response' do
      response = DHC.get('http://depay.fi')
      expect(response.body).to eq 'Im served from remote cache'
      LocalCacheInterceptor.cached = true
      response = DHC.get('http://depay.fi')
      expect(response.body).to eq 'Im served from local cache'
    end
  end
end
