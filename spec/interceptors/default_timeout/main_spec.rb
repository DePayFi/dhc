# frozen_string_literal: true

require 'rails_helper'

describe DHC::DefaultTimeout do
  before(:each) do
    DHC.config.interceptors = [DHC::DefaultTimeout]
    DHC::DefaultTimeout.timeout = nil
    DHC::DefaultTimeout.connecttimeout = nil
  end

  let(:stub) { stub_request(:get, 'http://depay.fi').to_return(status: 200, body: 'The Website') }

  it 'applies default timeouts to all requests made' do
    stub
    expect_any_instance_of(Ethon::Easy).to receive(:http_request)
      .with(anything, anything, hash_including(timeout: 15, connecttimeout: 2)).and_call_original
    DHC.get('http://depay.fi')
  end

  context 'with changed default timesouts' do
    before(:each) do
      DHC::DefaultTimeout.timeout = 10
      DHC::DefaultTimeout.connecttimeout = 3
    end

    it 'applies custom default timeouts to all requests made' do
      stub
      expect_any_instance_of(Ethon::Easy).to receive(:http_request)
        .with(anything, anything, hash_including(timeout: 10, connecttimeout: 3)).and_call_original
      DHC.get('http://depay.fi')
    end
  end
end
