# frozen_string_literal: true

require 'rails_helper'

describe DHC::Response do
  context 'headers' do
    let(:headers) do
      { 'Content-Encoding' => 'UTF-8' }
    end

    let(:raw_response) { OpenStruct.new(headers: headers) }

    it 'provides headers' do
      response = DHC::Response.new(raw_response, nil)
      expect(response.headers).to eq headers
    end
  end
end
