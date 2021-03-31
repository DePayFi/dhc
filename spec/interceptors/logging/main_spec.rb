# frozen_string_literal: true

require 'rails_helper'

describe DHC::Logging do
  let(:logger) { spy('logger') }

  before(:each) do
    DHC.config.interceptors = [DHC::Logging]
    DHC::Logging.logger = logger
    stub_request(:get, 'http://depay.fi').to_return(status: 200)
  end

  it 'does log information before and after every request made with DHC' do
    DHC.get('http://depay.fi')
    expect(logger).to have_received(:info).once.with(
      %r{Before DHC request <\d+> GET http://depay.fi at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Params={} Headers={.*?}}
    )
    expect(logger).to have_received(:info).once.with(
      %r{After DHC response for request <\d+> GET http://depay.fi at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Time=0ms URL=http://depay.fi:80/}
    )
  end

  context 'source' do
    let(:source) { '/Users/Sebastian/DHC/test.rb' }

    it 'does log the source if provided as option' do
      DHC.get('http://depay.fi', source: source)
      expect(logger).to have_received(:info).once.with(
        %r{Before DHC request <\d+> GET http://depay.fi at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Params={} Headers={.*?} \nCalled from #{source}}
      )
      expect(logger).to have_received(:info).once.with(
        %r{After DHC response for request <\d+> GET http://depay.fi at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Time=0ms URL=http://depay.fi:80/ \nCalled from #{source}}
      )
    end
  end
end
