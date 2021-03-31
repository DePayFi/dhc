# frozen_string_literal: true

require 'rails_helper'

describe DHC::Caching do
  context 'parameters' do
    before(:each) do
      DHC.config.interceptors = [DHC::Caching]
      Rails.cache.clear
    end

    it 'considers parameters when writing/reading from cache' do
      DHC.config.endpoint(:local, 'http://depay.fi', cache: true)
      stub_request(:get, 'http://depay.fi').to_return(status: 200, body: 'The Website')
      stub_request(:get, 'http://depay.fi?location=zuerich').to_return(status: 200, body: 'The Website for Zuerich')
      expect(
        DHC.get(:local).body
      ).to eq 'The Website'
      expect(
        DHC.get(:local, params: { location: 'zuerich' }).body
      ).to eq 'The Website for Zuerich'
    end
  end
end
