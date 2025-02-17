# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'post' do
    let(:feedback) do
      {
        recommended: true,
        source_id: 'aaa',
        content_ad_id: '1z-5r1fkaj'
      }
    end

    before(:each) do
      stub_request(:post, 'http://datastore/v2/feedbacks')
        .with(body: feedback.to_json)
        .to_return(status: 200, body: feedback.to_json, headers: { 'Content-Encoding' => 'UTF-8' })
    end

    it 'does a post request when providing a complete url' do
      DHC.post('http://datastore/v2/feedbacks', body: feedback)
    end

    it 'does a post request when providing the name of a configured endpoint' do
      url = 'http://{+datastore}/v2/feedbacks'
      options = { params: { datastore: 'datastore' } }
      DHC.configure { |c| c.endpoint(:feedbacks, url, options) }
      DHC.post(:feedbacks, body: feedback)
    end

    it 'makes response data available' do
      response = DHC.post('http://datastore/v2/feedbacks', body: feedback)
      expect(response.data['source_id']).to eq 'aaa'
    end

    it 'provides response headers' do
      response = DHC.post('http://datastore/v2/feedbacks', body: feedback)
      expect(response.headers).to be_present
    end
  end
end
