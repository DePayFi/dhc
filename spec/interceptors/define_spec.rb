# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < DHC::Interceptor
      end
      class AnotherInterceptor < DHC::Interceptor
      end
    end

    it 'performs interceptor when they are set globally' do
      DHC.configure { |c| c.interceptors = [SomeInterceptor] }
      expect_any_instance_of(SomeInterceptor).to receive(:before_request)
      stub_request(:get, 'http://depay.fi')
      DHC.get('http://depay.fi')
    end

    it 'overrides interceptors on request level' do
      DHC.configure { |c| c.interceptors = [SomeInterceptor] }
      expect_any_instance_of(AnotherInterceptor).to receive(:before_request)
      expect_any_instance_of(SomeInterceptor).not_to receive(:before_request)
      stub_request(:get, 'http://depay.fi')
      DHC.get('http://depay.fi', interceptors: [AnotherInterceptor])
    end
  end
end
