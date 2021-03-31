# frozen_string_literal: true

require 'rails_helper'

describe DHC::Request do
  let(:request_options) do
    [
      { url: 'http://www.depay.fi/restaurants' },
      { url: 'http://www.depay.fi' }
    ]
  end

  let(:stub_parallel_requests) do
    stub_request(:get, "http://www.depay.fi/restaurants").to_return(status: 200, body: '1')
    stub_request(:get, "http://www.depay.fi").to_return(status: 200, body: '2')
  end

  it 'does parallel requests if you provide an array of requests' do
    stub_parallel_requests
    responses = DHC.request(request_options)
    expect(responses[0].body).to eq '1'
    expect(responses[1].body).to eq '2'
  end

  context 'interceptors' do
    before(:each) do
      class TestInterceptor < DHC::Interceptor; end
      DHC.configure { |c| c.interceptors = [TestInterceptor] }
    end

    it 'calls interceptors also for parallel requests' do
      stub_parallel_requests
      @called = 0
      allow_any_instance_of(TestInterceptor)
        .to receive(:before_request) { @called += 1 }
      DHC.request(request_options)
      expect(@called).to eq 2
    end
  end

  context 'webmock disabled' do
    before do
      WebMock.disable!
    end

    after do
      WebMock.enable!
    end

    it 'does not memorize parallelization handlers in typhoeus (hydra) in case one request of the parallization fails' do
      begin
        DHC.request([{ url: 'https://www.google.com/' }, { url: 'https://nonexisting123' }, { url: 'https://www.google.com/' }, { url: 'https://nonexisting123' }])
      rescue DHC::UnknownError
      end

      DHC.request([{ url: 'https://www.google.com' }])
    end
  end
end
