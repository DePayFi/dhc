# frozen_string_literal: true

require 'rails_helper'

describe DHC::Rollbar do
  before(:each) do
    DHC.config.interceptors = [DHC::Rollbar]
  end

  context 'Rollbar is undefined' do
    before(:each) do
      Object.send(:remove_const, 'Rollbar') if Object.const_defined?('Rollbar')
    end
    it 'does not report' do
      stub_request(:get, 'http://depay.fi').to_return(status: 400)
      expect(-> { DHC.get('http://depay.fi') })
        .to raise_error DHC::BadRequest
    end
  end

  context 'Rollbar is defined' do
    before(:each) do
      class Rollbar; end
      ::Rollbar.stub(:warning)
    end

    it 'does report errors to rollbar' do
      stub_request(:get, 'http://depay.fi').to_return(status: 400)
      expect(-> { DHC.get('http://depay.fi') })
        .to raise_error DHC::BadRequest
      expect(::Rollbar).to have_received(:warning)
        .with(
          'Status: 400 URL: http://depay.fi',
          response: hash_including(body: anything, code: anything, headers: anything, time: anything, timeout?: anything),
          request: hash_including(url: anything, method: anything, headers: anything, params: anything)
        )
    end

    context 'additional params' do
      it 'does report errors to rollbar with additional data' do
        stub_request(:get, 'http://depay.fi')
          .to_return(status: 400)
        expect(-> { DHC.get('http://depay.fi', rollbar: { additional: 'data' }) })
          .to raise_error DHC::BadRequest
        expect(::Rollbar).to have_received(:warning)
          .with(
            'Status: 400 URL: http://depay.fi',
            hash_including(
              response: anything,
              request: anything,
              additional: 'data'
            )
          )
      end
    end
  end
end
