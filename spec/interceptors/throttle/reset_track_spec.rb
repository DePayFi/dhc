# frozen_string_literal: true

require 'rails_helper'

describe DHC::Throttle do
  let(:provider) { 'depay.fi' }
  let(:limit) { 10_000 }
  let(:remaining) { 1900 }
  let(:options) do
    {
      throttle: {
        provider: provider,
        track: true,
        limit: limit_options,
        remaining: { header: 'Rate-Limit-Remaining' },
        expires: { header: 'Rate-Limit-Reset' },
        break: '80%'
      }
    }
  end
  let(:limit_options) { { header: 'Rate-Limit-Limit' } }
  let(:break_option) { false }
  let(:expires_in) { (Time.zone.now + 1.hour).to_i }

  before(:each) do
    DHC.config.interceptors = [DHC::Throttle]

    stub_request(:get, 'http://depay.fi')
      .to_return(
        headers: {
          'Rate-Limit-Limit' => limit,
          'Rate-Limit-Remaining' => remaining,
          'Rate-Limit-Reset' => expires_in
        }
      )
  end

  # If DHC::Trottle.track would be kept accross multiple tests,
  # at least 2/3 of the following would fail

  it 'resets track accross multiple tests 1/3' do
    DHC.get('http://depay.fi', options)
  end

  it 'resets track accross multiple tests 2/3' do
    DHC.get('http://depay.fi', options)
  end

  it 'resets track accross multiple tests 3/3' do
    DHC.get('http://depay.fi', options)
  end
end
