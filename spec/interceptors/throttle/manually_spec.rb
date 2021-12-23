# frozen_string_literal: true

require 'rails_helper'

describe DHC::Throttle do
  let(:options) do
    {
      throttle: {
        provider: provider,
        track: true,
        limit: quota_limit,
        expires: 1.minute,
        break: break_after
      }
    }
  end

  let(:provider) { 'depay.fi' }
  let(:quota_limit) { 100 }
  let(:break_after) { '80%' }

  before(:each) do
    DHC.config.interceptors = [DHC::Throttle]
    Rails.cache.write(DHC::Throttle::CACHE_KEY, nil)

    stub_request(:get, 'http://depay.fi').to_return(status: 200)
  end

  it 'tracks the request limits based on response data' do
    DHC.get('http://depay.fi', options)
    expect(Rails.cache.read('DHC/throttle/tracker/v1')[provider][:limit]).to eq 100
    expect(Rails.cache.read('DHC/throttle/tracker/v1')[provider][:remaining]).to eq quota_limit - 1
  end

  context 'breaks' do
    let(:quota_limit) { 100 }
    let(:break_after) { '79%' }

    it 'hit the breaks if throttling quota is reached' do
      79.times do
        DHC.get('http://depay.fi', options)
      end
      expect { DHC.get('http://depay.fi', options) }.to raise_error(
        DHC::Throttle::OutOfQuota,
        'Reached predefined quota for depay.fi'
      )
    end

    context 'still within quota' do
      let(:break_after) { '80%' }

      it 'does not hit the breaks' do
        80.times do
          DHC.get('http://depay.fi', options)
        end
      end

      it 'does hit the breaks surpassing quota' do
        80.times do
          DHC.get('http://depay.fi', options)
        end
        expect { DHC.get('http://depay.fi', options) }.to raise_error(
          DHC::Throttle::OutOfQuota,
          'Reached predefined quota for depay.fi'
        )
      end
    end
  end

  context 'expires' do
    let(:break_after) { '80%' }
    let(:quota_limit) { 100 }

    it 'attempts another request if the quota expired' do
      80.times do
        DHC.get('http://depay.fi', options)
      end
      expect { DHC.get('http://depay.fi', options) }.to raise_error(
        DHC::Throttle::OutOfQuota,
        'Reached predefined quota for depay.fi'
      )
      Timecop.travel(Time.zone.now + 1.minute)
      80.times do
        DHC.get('http://depay.fi', options)
      end
      expect { DHC.get('http://depay.fi', options) }.to raise_error(
        DHC::Throttle::OutOfQuota,
        'Reached predefined quota for depay.fi'
      )
    end
  end

  context 'multiple provider' do
    it 'tracks multiple providers without a problem' do
      DHC.get('http://depay.fi', options)
      stub_request(:get, 'http://depay.app').to_return(status: 200)
      DHC.get('http://depay.app', {
                throttle: {
                  provider: 'depay.app',
                  track: true,
                  limit: quota_limit,
                  expires: 1.minute,
                  break: break_after
                }
              })
      expect(Rails.cache.read('DHC/throttle/tracker/v1')['depay.fi']).to be_present
      expect(Rails.cache.read('DHC/throttle/tracker/v1')['depay.app']).to be_present
    end
  end
end
