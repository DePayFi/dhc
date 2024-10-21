# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'get' do
    before(:each) do
      stub_request(:get, 'http://datastore/v2/feedbacks?has_reviews=true')
        .to_return(status: 200, body: { total: 99 }.to_json, headers: { 'Content-Encoding' => 'UTF-8' })
    end

    let(:parameters) do
      { has_reviews: true }
    end

    it 'does a get request when providing a complete url' do
      DHC.get('http://datastore/v2/feedbacks', params: parameters)
    end

    it 'does a get request when providing the name of a configured endpoint' do
      url = 'http://{+datastore}/v2/feedbacks'
      options = { params: { datastore: 'datastore' } }
      DHC.configure { |c| c.endpoint(:feedbacks, url, options) }
      DHC.get(:feedbacks, params: parameters)
    end

    it 'makes response data available' do
      response = DHC.get('http://datastore/v2/feedbacks', params: parameters)
      expect(response.data['total']).to eq 99
    end

    it 'provides response headers' do
      response = DHC.get('http://datastore/v2/feedbacks', params: parameters)
      expect(response.headers).to be_present
    end
  end

  context 'get json' do
    before(:each) do
      stub_request(:get, 'http://datastore/v2/feedbacks').with(headers: { 'Content-Type' => 'application/json; charset=utf-8' })
        .to_return(body: { some: 'json' }.to_json)
    end

    it 'requests json and parses response body' do
      data = DHC.json.get('http://datastore/v2/feedbacks').data
      expect(data['some']).to eq 'json'
    end
  end
end
