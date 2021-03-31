# frozen_string_literal: true

require 'rails_helper'

describe DHC::Response do
  context 'body' do
    let(:body) { 'this is a body' }

    let(:raw_response) { OpenStruct.new(body: body) }

    it 'provides response body' do
      response = DHC::Response.new(raw_response, nil)
      expect(response.body).to eq body
    end
  end
end
