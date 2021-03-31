# frozen_string_literal: true

require 'rails_helper'

describe DHC::Request do
  it 'does not alter the options that where passed' do
    DHC.configure { |c| c.endpoint(:kpi_tracker, 'http://analytics/track/{entity_id}/w', params: { env: 'PROD' }) }
    options = { params: { entity_id: '123' } }
    stub_request(:get, 'http://analytics/track/123/w?env=PROD')
    DHC.get(:kpi_tracker, options)
    expect(options).to eq(params: { entity_id: '123' })
  end
end
