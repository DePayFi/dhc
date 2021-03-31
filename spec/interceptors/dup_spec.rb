# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < DHC::Interceptor
      end
    end

    it 'does not dup' do
      options = { interceptors: [SomeInterceptor] }
      expect(
        options.deep_dup[:interceptors].include?(SomeInterceptor)
      ).to eq true
    end
  end
end
