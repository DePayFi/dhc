# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'interceptor' do
    before(:each) do
      class TrackingIdInterceptor < DHC::Interceptor
        def before_request
          request.params[:tid] = 123
        end
      end
      DHC.configure { |c| c.interceptors = [TrackingIdInterceptor] }
    end

    it 'can modify requests before they are send' do
      stub_request(:get, "http://depay.fi/?tid=123")
      DHC.get('http://depay.fi')
    end
  end
end
