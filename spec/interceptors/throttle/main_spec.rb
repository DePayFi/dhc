# frozen_string_literal: true

require 'rails_helper'

describe DHC::Throttle do
  let(:options_break) { false }
  let(:options_expires) { { header: 'reset' } }
  let(:options_limit) { { header: 'limit' } }
  let(:options_remaining) { { header: 'remaining' } }
  let(:provider) { 'depay.fi' }
  let(:quota_limit) { 10_000 }
  let(:quota_remaining) { 1900 }
  let(:quota_reset) { (Time.zone.now + 1.hour).to_i }
  let(:options) do
    {
      throttle: {
        provider: provider,
        track: true,
        limit: options_limit,
        remaining: options_remaining,
        expires: options_expires,
        break: options_break
      }
    }
  end

  before(:each) do
    DHC.config.interceptors = [DHC::Throttle]
    Rails.cache.write(DHC::Throttle::CACHE_KEY, nil)

    stub_request(:get, 'http://depay.fi').to_return(
      headers: { 'limit' => quota_limit, 'remaining' => quota_remaining, 'reset' => quota_reset }
    )
  end

  it 'tracks the request limits based on response data' do
    DHC.get('http://depay.fi', options)
    expect(Rails.cache.read('DHC/throttle/tracker/v1')[provider][:limit]).to eq quota_limit
    expect(Rails.cache.read('DHC/throttle/tracker/v1')[provider][:remaining]).to eq quota_remaining
  end

  context 'fix predefined integer for limit' do
    let(:options_limit) { 1000 }

    it 'tracks the limit based on initialy provided data' do
      DHC.get('http://depay.fi', options)
      expect(Rails.cache.read('DHC/throttle/tracker/v1')[provider][:limit]).to eq options_limit
    end
  end

  context 'breaks' do
    let(:options_break) { '80%' }

    it 'hit the breaks if throttling quota is reached' do
      DHC.get('http://depay.fi', options)
      expect { DHC.get('http://depay.fi', options) }.to raise_error(
        DHC::Throttle::OutOfQuota,
        'Reached predefined quota for depay.fi'
      )
    end

    context 'still within quota' do
      let(:options_break) { '90%' }

      it 'does not hit the breaks' do
        DHC.get('http://depay.fi', options)
        DHC.get('http://depay.fi', options)
      end
    end
  end

  context 'no response headers' do
    before { stub_request(:get, 'http://depay.fi').to_return(status: 200) }

    it 'does not raise an exception' do
      DHC.get('http://depay.fi', options)
    end

    context 'no remaining tracked, but break enabled' do
      let(:options_break) { '90%' }

      it 'does not fail if a remaining was not tracked yet' do
        DHC.get('http://depay.fi', options)
        DHC.get('http://depay.fi', options)
      end
    end
  end

  context 'expires' do
    let(:options_break) { '80%' }

    it 'attempts another request if the quota expired' do
      DHC.get('http://depay.fi', options)
      expect { DHC.get('http://depay.fi', options) }.to raise_error(
        DHC::Throttle::OutOfQuota,
        'Reached predefined quota for depay.fi'
      )
      Timecop.travel(Time.zone.now + 2.hours)
      DHC.get('http://depay.fi', options)
    end
  end

  describe 'configuration values as Procs' do
    describe 'calculate "limit" in proc' do
      let(:options_limit) do
        ->(*) { 10_000 }
      end

      before(:each) do
        DHC.get('http://depay.fi', options)
      end

      context 'breaks' do
        let(:options_break) { '80%' }

        it 'hit the breaks if throttling quota is reached' do
          expect { DHC.get('http://depay.fi', options) }.to raise_error(
            DHC::Throttle::OutOfQuota,
            'Reached predefined quota for depay.fi'
          )
        end

        context 'still within quota' do
          let(:options_break) { '90%' }

          it 'does not hit the breaks' do
            DHC.get('http://depay.fi', options)
          end
        end
      end
    end

    describe 'calculate "remaining" in proc' do
      let(:quota_current) { 8100 }
      let(:options_remaining) do
        ->(response) { response.headers['limit'].to_i - response.headers['current'].to_i }
      end

      before(:each) do
        stub_request(:get, 'http://depay.fi').to_return(
          headers: { 'limit' => quota_limit, 'current' => quota_current, 'reset' => quota_reset }
        )
        DHC.get('http://depay.fi', options)
      end

      context 'breaks' do
        let(:options_break) { '80%' }

        it 'hit the breaks if throttling quota is reached' do
          expect { DHC.get('http://depay.fi', options) }.to raise_error(
            DHC::Throttle::OutOfQuota,
            'Reached predefined quota for depay.fi'
          )
        end

        context 'still within quota' do
          let(:options_break) { '90%' }

          it 'does not hit the breaks' do
            DHC.get('http://depay.fi', options)
          end
        end
      end
    end

    describe 'calculate "reset" in proc' do
      let(:options_expires) { ->(*) { Time.zone.now + 1.second } }

      before(:each) do
        stub_request(:get, 'http://depay.fi').to_return(
          headers: { 'limit' => quota_limit, 'remaining' => quota_remaining }
        )
        DHC.get('http://depay.fi', options)
      end

      context 'breaks' do
        let(:options_break) { '80%' }

        it 'hit the breaks if throttling quota is reached' do
          expect { DHC.get('http://depay.fi', options) }.to raise_error(
            DHC::Throttle::OutOfQuota,
            'Reached predefined quota for depay.fi'
          )
        end

        context 'still within quota' do
          let(:options_break) { '90%' }

          it 'does not hit the breaks' do
            DHC.get('http://depay.fi', options)
          end
        end
      end
    end
  end

  describe 'parsing reset time given in prose' do
    let(:quota_reset) { (Time.zone.now + 1.day).strftime('%A, %B %d, %Y 12:00:00 AM GMT').to_s }

    before { DHC.get('http://depay.fi', options) }

    context 'breaks' do
      let(:options_break) { '80%' }

      it 'hit the breaks if throttling quota is reached' do
        expect { DHC.get('http://depay.fi', options) }.to raise_error(
          DHC::Throttle::OutOfQuota,
          'Reached predefined quota for depay.fi'
        )
      end

      context 'still within quota' do
        let(:options_break) { '90%' }

        it 'does not hit the breaks' do
          DHC.get('http://depay.fi', options)
        end
      end
    end
  end

  context 'when value is empty' do
    let(:quota_reset) { nil }

    before do
      stub_request(:get, 'http://depay.fi').to_return(
        headers: { 'limit' => quota_limit, 'remaining' => quota_remaining }
      )
      DHC.get('http://depay.fi', options)
    end

    it 'still runs' do
      DHC.get('http://depay.fi', options)
    end
  end
end
