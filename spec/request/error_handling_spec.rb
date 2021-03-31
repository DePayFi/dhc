# frozen_string_literal: true

require 'rails_helper'

describe DHC::Request do
  context 'error handling' do
    def to_fail_with(error)
      raise_error(error)
    end

    def expect_status_code(status_code)
      stub_request(:get, "http://something/#{status_code}").to_return(status: status_code)
      expect(
        -> { DHC::Request.new(url: "http://something/#{status_code}") }
      ).to yield
    end

    it 'raises errors for anything but 2XX response codes' do
      expect_status_code(0)   { to_fail_with(DHC::UnknownError) }
      expect_status_code(400) { to_fail_with(DHC::BadRequest) }
      expect_status_code(401) { to_fail_with(DHC::Unauthorized) }
      expect_status_code(402) { to_fail_with(DHC::PaymentRequired) }
      expect_status_code(403) { to_fail_with(DHC::Forbidden) }
      expect_status_code(403) { to_fail_with(DHC::Forbidden) }
      expect_status_code(404) { to_fail_with(DHC::NotFound) }
      expect_status_code(405) { to_fail_with(DHC::MethodNotAllowed) }
      expect_status_code(406) { to_fail_with(DHC::NotAcceptable) }
      expect_status_code(407) { to_fail_with(DHC::ProxyAuthenticationRequired) }
      expect_status_code(408) { to_fail_with(DHC::RequestTimeout) }
      expect_status_code(409) { to_fail_with(DHC::Conflict) }
      expect_status_code(410) { to_fail_with(DHC::Gone) }
      expect_status_code(411) { to_fail_with(DHC::LengthRequired) }
      expect_status_code(412) { to_fail_with(DHC::PreconditionFailed) }
      expect_status_code(413) { to_fail_with(DHC::RequestEntityTooLarge) }
      expect_status_code(414) { to_fail_with(DHC::RequestUriToLong) }
      expect_status_code(415) { to_fail_with(DHC::UnsupportedMediaType) }
      expect_status_code(416) { to_fail_with(DHC::RequestedRangeNotSatisfiable) }
      expect_status_code(417) { to_fail_with(DHC::ExpectationFailed) }
      expect_status_code(422) { to_fail_with(DHC::UnprocessableEntity) }
      expect_status_code(423) { to_fail_with(DHC::Locked) }
      expect_status_code(424) { to_fail_with(DHC::FailedDependency) }
      expect_status_code(426) { to_fail_with(DHC::UpgradeRequired) }
      expect_status_code(500) { to_fail_with(DHC::InternalServerError) }
      expect_status_code(501) { to_fail_with(DHC::NotImplemented) }
      expect_status_code(502) { to_fail_with(DHC::BadGateway) }
      expect_status_code(503) { to_fail_with(DHC::ServiceUnavailable) }
      expect_status_code(504) { to_fail_with(DHC::GatewayTimeout) }
      expect_status_code(505) { to_fail_with(DHC::HttpVersionNotSupported) }
      expect_status_code(507) { to_fail_with(DHC::InsufficientStorage) }
      expect_status_code(510) { to_fail_with(DHC::NotExtended) }
    end
  end

  context 'parsing error' do
    before(:each) do
      stub_request(:get, 'http://datastore/v2/feedbacks').to_return(body: 'invalid json')
    end

    it 'requests json and parses response body' do
      expect(-> {
        DHC.json.get('http://datastore/v2/feedbacks').data
      }).to raise_error(DHC::ParserError)
    end
  end

  context 'custom error handler' do
    it 'handles errors with the provided handler and does not raise them' do
      stub_request(:get, 'http://something').to_return(status: 400)
      handler = double('handler', call: -> {})
      DHC::Request.new(url: 'http://something', rescue: handler)
      expect(handler).to have_received(:call)
    end

    it 'exchanges body with handlers return if the handler returns something' do
      stub_request(:get, 'http://something').to_return(status: 400)
      handler = ->(_response) { { name: 'unknown' }.to_json }
      request = DHC::Request.new(url: 'http://something', rescue: handler)
      expect(request.response.data.name).to eq 'unknown'
    end

    it 'does not exchange body with handlers return if the handler returns nil' do
      stub_request(:get, 'http://something').to_return(status: 400, body: { message: 'an error occurred' }.to_json)
      handler = ->(_response) { nil }
      request = DHC::Request.new(url: 'http://something', rescue: handler)
      expect(request.response.data.message).to eq 'an error occurred'
    end
  end
end
