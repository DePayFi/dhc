# frozen_string_literal: true

require 'rails_helper'

describe DHC::Response do
  context 'code' do
    let(:code) { 200 }

    let(:raw_response) { OpenStruct.new(code: code) }

    it 'provides response code' do
      response = DHC::Response.new(raw_response, nil)
      expect(response.code).to eq code
    end
  end
end
