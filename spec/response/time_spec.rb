# frozen_string_literal: true

require 'rails_helper'

describe DHC::Response do
  context 'time' do
    let(:time) { 1.3 }

    let(:raw_response) { OpenStruct.new(time: time) }

    it 'provides response time in seconds' do
      response = DHC::Response.new(raw_response, nil)
      expect(response.time).to eq time
    end

    it 'provides response time in miliseconds' do
      response = DHC::Response.new(raw_response, nil)
      expect(response.time_ms).to eq time * 1000
    end
  end
end
