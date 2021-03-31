# frozen_string_literal: true

require 'rails_helper'

describe DHC::Caching do
  context 'to_cache' do
    it 'returns a marshalable object to store in the cache' do
      expect do
        response = Typhoeus::Response.new(headers: { 'Accept' => 'application/json' })
        Marshal.dump(
          DHC::Caching.new(response).send(:to_cache, response)
        )
      end.not_to raise_error
    end
  end
end
