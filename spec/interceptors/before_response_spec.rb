# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < DHC::Interceptor
        def before_response; end
      end
      DHC.configure { |c| c.interceptors = [SomeInterceptor] }
    end

    it 'can perform some actions before a reponse is received' do
      expect_any_instance_of(SomeInterceptor).to receive(:before_response)
      stub_request(:get, 'http://depay.fi')
      DHC.get('http://depay.fi')
    end
  end
end
