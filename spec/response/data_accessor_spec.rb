# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'data accessor (hash with indifferent access)' do
    before(:each) do
      stub_request(:get, 'http://depay.fi/')
        .with(headers: {
                'Accept' => 'application/json,application/vnd.api+json',
                'Content-Type' => 'application/json; charset=utf-8',
                'Accept-Charset' => 'utf-8'
              })
        .to_return(body: { 'MyProp' => 'MyValue' }.to_json)
    end

    it 'makes data accessible with square bracket accessor (string)' do
      expect(
        DHC.json.get('http://depay.fi')['MyProp']
      ).to eq 'MyValue'
    end

    it 'makes data accessible with square bracket accessor (symbol)' do
      expect(
        DHC.json.get('http://depay.fi')[:MyProp]
      ).to eq 'MyValue'
    end
  end
end
