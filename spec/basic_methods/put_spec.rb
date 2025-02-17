# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'post' do
    let(:feedback) do
      {
        recommended: false,
        source_id: 'aaa',
        content_ad_id: '1z-5r1fkaj'
      }
    end

    let(:change) do
      {
        recommended: false
      }
    end

    before(:each) do
      stub_request(:put, 'http://datastore/v2/feedbacks')
        .with(body: change.to_json)
        .to_return(status: 200, body: feedback.merge(change).to_json, headers: { 'Content-Encoding' => 'UTF-8' })
    end

    it 'does a post request when providing a complete url' do
      DHC.put('http://datastore/v2/feedbacks', body: change)
    end

    it 'does a post request when providing the name of a configured endpoint' do
      url = 'http://{+datastore}/v2/feedbacks'
      options = { params: { datastore: 'datastore' } }
      DHC.configure { |c| c.endpoint(:feedbacks, url, options) }
      DHC.put(:feedbacks, body: change)
    end

    it 'makes response data available' do
      response = DHC.put('http://datastore/v2/feedbacks', body: change)
      expect(response.data['recommended']).to eq false
    end

    it 'provides response headers' do
      response = DHC.put('http://datastore/v2/feedbacks', body: change)
      expect(response.headers).to be_present
    end
  end
end
