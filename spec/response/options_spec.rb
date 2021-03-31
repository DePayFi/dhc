# frozen_string_literal: true

require 'rails_helper'

describe DHC::Response do
  context 'headers' do
    let(:options) do
      { 'return_code' => :ok }
    end

    let(:raw_response) { OpenStruct.new(options: options) }

    it 'provides headers' do
      response = DHC::Response.new(raw_response, nil)
      expect(response.options).to eq options
    end
  end
end
