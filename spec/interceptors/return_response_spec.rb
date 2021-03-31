# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'interceptor' do
    before(:each) do
      class CacheInterceptor < DHC::Interceptor

        def before_request
          DHC::Response.new(Typhoeus::Response.new(response_code: 200, return_code: :ok, response_body: 'Im served from cache'), nil)
        end
      end
      DHC.configure { |c| c.interceptors = [CacheInterceptor] }
    end

    it 'can return a response rather then doing a real request' do
      response = DHC.get('http://depay.fi')
      expect(response.body).to eq 'Im served from cache'
    end

    context 'misusage' do
      before(:each) do
        class AnotherInterceptor < DHC::Interceptor
          def before_request
            DHC::Response.new(Typhoeus::Response.new(response_code: 200, return_code: :ok), nil)
          end
        end
      end

      it 'raises an exception when two interceptors try to return a response' do
        expect(lambda {
          DHC.get('http://depay.fi', interceptors: [CacheInterceptor, AnotherInterceptor])
        }).to raise_error 'Response already set from another interceptor'
      end
    end
  end
end
