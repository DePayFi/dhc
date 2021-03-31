# frozen_string_literal: true

require 'rails_helper'

describe DHC::Endpoint do
  context 'match' do
    context 'matching' do
      {
        '{+datastore}/v2/places' => 'http://depay.fi:8082/v2/places',
        '{+datastore}/v2/places/{id}' => 'http://depay.fi:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A',
        '{+datastore}/v2/places/{namespace}/{id}' => 'http://depay.fi:8082/v2/places/switzerland/ZW9OJyrbt',
        '{+datastore}/addresses/{id}' => 'http://depay.fi/addresses/123',
        'http://depay.fi/addresses/{id}' => 'http://depay.fi/addresses/123',
        '{+datastore}/customers/{id}/addresses' => 'http://depay.fi:80/server/rest/v1/customers/123/addresses',
        '{+datastore}/entries/{id}.json' => 'http://depay.fi/entries/123.json',
        '{+datastore}/places/{place_id}/feedbacks' => 'http://depay.fi/places/1/feedbacks?limit=10&offset=0',
        'http://depay.fi/places/1/feedbacks' => 'http://depay.fi/places/1/feedbacks?lang=en',
        'http://depay.fi/places/1/feedbacks.json' => 'http://depay.fi/places/1/feedbacks.json?lang=en'
      }.each do |template, url|
        it "#{url} matches #{template}" do
          expect(DHC::Endpoint.match?(url, template)).to be(true)
        end
      end
    end

    context 'not matching' do
      {
        '{+datastore}/v2/places' => 'http://depay.fi:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A',
        '{+datastore}/{campaign_id}/feedbacks' => 'http://datastore.depay.fi/feedbacks',
        '{+datastore}/customers/{id}' => 'http://depay.fi:80/server/rest/v1/customers/123/addresses',
        '{+datastore}/entries/{id}' => 'http://depay.fi/entries/123.json'
      }.each do |template, url|
        it "#{url} should not match #{template}" do
          expect(
            DHC::Endpoint.match?(url, template)
          ).to be(false)
        end
      end
    end
  end
end
