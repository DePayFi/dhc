# frozen_string_literal: true

require 'rails_helper'

describe DHC::Response do
  context 'data' do
    let(:value) { 'some_value' }

    let(:raw_response) { OpenStruct.new(body: body.to_json) }

    let(:response) { DHC::Response.new(raw_response, nil) }

    context 'for item' do
      let(:body) { { some_key: { nested: value } } }

      it 'makes data from response body available' do
        expect(response.data.dig('some_key', 'nested')).to eq value
      end

      it 'can be converted to json with the as_json method' do
        expect(response.data.as_json).to eq body.as_json
      end

      it 'returns nil when data is not available' do
        expect(response.data['something']).to be_nil
      end
    end

    context 'for collection' do
      let(:body) { [{ some_key: { nested: value } }] }

      it 'can be converted to json with the as_json method' do
        expect(response.data.as_json).to eq body.as_json
      end

      it 'makes item data from response body available' do
        expect(response.data.dig(0, 'some_key', 'nested')).to eq value
      end
    end
  end

  context 'response data if responding error data contains a response' do
    before do
      stub_request(:get, 'http://listings/')
        .to_return(status: 404, body: {
          meta: {
            errors: [
              { code: 2000, msg: 'I like to hide error messages (this is meta).' }
            ]
          },
          response: 'why not?'
        }.to_json)
    end

    it 'does not throw a stack level to deep issue when accessing data in a rescue context' do
      begin
        DHC.get('http://listings')
      rescue DHC::Error => error
        expect(
          error.response.request.response.data.dig('meta', 'errors').detect { |item| item['code'] == 2000 }['msg']
        ).to eq 'I like to hide error messages (this is meta).'
      end
    end
  end
end
