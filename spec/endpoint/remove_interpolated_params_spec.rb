# frozen_string_literal: true

require 'rails_helper'

describe DHC::Endpoint do
  it 'removes params used for interpolation' do
    params = {
      datastore: 'http://datastore',
      campaign_id: 'abc',
      has_reviews: true
    }
    endpoint = DHC::Endpoint.new('{+datastore}/v2/{campaign_id}/feedbacks')
    removed = endpoint.remove_interpolated_params!(params)
    expect(params).to eq(has_reviews: true)
    expect(removed).to eq(datastore: 'http://datastore', campaign_id: 'abc')
  end
end
