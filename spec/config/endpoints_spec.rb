# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'configured endpoints' do
    let(:url) { 'http://analytics/track/{entity_id}/w/{type}' }

    let(:options) do
      {
        params: { env: 'PROD' },
        followlocation: false
      }
    end

    before(:each) do
      DHC.configure do |c|
        c.endpoint(:kpi_tracker, url, options)
      end
    end

    it 'configures urls to be able to access them by name later' do
      expect(DHC.config.endpoints[:kpi_tracker].url).to eq url
      expect(DHC.config.endpoints[:kpi_tracker].options).to eq options
    end

    it 'compile url' do
      stub_request(:get, 'http://analytics/track/123/w/request?env=PROD')
      response = DHC.get(:kpi_tracker, params: { entity_id: 123, type: 'request' })
      expect(response.request.options[:followlocation]).to eq false
    end

    it 'gets overwritten by explicit request options' do
      stub_request(:get, 'http://analytics/track/123/w/request?env=STG')
      DHC.get(:kpi_tracker, params: { entity_id: 123, type: 'request', env: 'STG' })
    end

    it 'raises in case of claching endpoint names' do
      expect(lambda {
        DHC.config.endpoint(:kpi_tracker, 'http://kpi-tracker')
      }).to raise_error 'Endpoint already exists for that name'
    end

    it 'enforces endpoint name to be a symbol' do
      DHC.configure { |c| c.endpoint('datastore', 'http://datastore') }
      expect(DHC.config.endpoints[:datastore].url).to eq 'http://datastore'
    end
  end

  context 'configured enpoints with default params' do
    before(:each) do
      DHC.config.endpoint(:telemarketers, 'http://datastore/v2/spamnumbers?order_by=-user_frequency&swiss_number=true&offset=0&limit=:limit', params: { limit: 200 })
      stub_request(:get, 'http://datastore/v2/spamnumbers?limit=200&offset=0&order_by=-user_frequency&swiss_number=true')
        .to_return(status: 200)
    end

    it 'is possible to call them multiple times with default params' do
      DHC.get(:telemarketers)
      DHC.get(:telemarketers)
      DHC.get(:telemarketers)
    end
  end
end
