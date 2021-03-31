# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < DHC::Interceptor
        def after_request; end
      end
      DHC.configure { |c| c.interceptors = [SomeInterceptor] }
    end

    it 'can perform some actions after a request was fired' do
      expect_any_instance_of(SomeInterceptor).to receive(:after_request)
      stub_request(:get, 'http://depay.fi')
      DHC.get('http://depay.fi')
    end
  end
end
