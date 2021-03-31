# frozen_string_literal: true

require 'addressable'
require 'rails_helper'

describe DHC::Request do
  context 'encoding url' do
    let(:url) { 'http://depay.fi/something with spaces' }

    it 'can request urls with spaces inside' do
      stub_request(:get, Addressable::URI.encode(url))
      DHC.get(url)
    end
  end

  context 'encoding params' do
    let(:url) { 'http://depay.fi/api/search?name=:name' }

    it 'can do requests with params including spaces' do
      stub_request(:get, 'http://depay.fi/api/search?name=My%20name%20is%20rabbit')
      DHC.get(url, params: { name: 'My name is rabbit' })
    end
  end

  context 'skip encoding' do
    let(:url) { 'http://depay.fi/api/search?names[]=seba&names[]=david' }

    it 'does not encode if encoding is skipped' do
      stub_request(:get, 'http://depay.fi/api/search?names%5B%5D%3Dseba%26names%5B%5D%3Ddavid')
      DHC.get('http://depay.fi/api/search?names%5B%5D%3Dseba%26names%5B%5D%3Ddavid', url_encoding: false)
    end

    it 'does double encoding, if you really want to' do
      stub_request(:get, 'http://depay.fi/api/search?names%255B%255D%253Dseba%2526names%255B%255D%253Ddavid')
      DHC.get('http://depay.fi/api/search?names%5B%5D%3Dseba%26names%5B%5D%3Ddavid')
    end
  end
end
