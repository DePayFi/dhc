# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'delete' do
    let(:feedback) do
      {
        recommended: true,
        source_id: 'aaa',
        content_ad_id: '1z-5r1fkaj'
      }
    end

    before(:each) do
      stub_request(:delete, 'http://datastore/v2/feedbacks/12121')
        .to_return(status: 200, body: feedback.to_json, headers: { 'Content-Encoding' => 'UTF-8' })
    end

    it 'does a delete request when providing a complete url' do
      DHC.delete('http://datastore/v2/feedbacks/12121')
    end

    it 'makes response data available' do
      response = DHC.delete('http://datastore/v2/feedbacks/12121')
      expect(response.data['recommended']).to eq true
    end

    it 'provides response headers' do
      response = DHC.delete('http://datastore/v2/feedbacks/12121')
      expect(response.headers).to be_present
    end
  end
end
