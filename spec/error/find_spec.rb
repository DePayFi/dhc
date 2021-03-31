# frozen_string_literal: true

require 'rails_helper'

describe DHC::Error do
  def response(code, timedout = false)
    DHC::Response.new(OpenStruct.new(code: code, 'timed_out?' => timedout), nil)
  end

  context 'find' do
    it 'finds error class by status code' do
      expect(DHC::Error.find(response('0', true))).to eq DHC::Timeout
      expect(DHC::Error.find(response('400'))).to eq DHC::BadRequest
      expect(DHC::Error.find(response('401'))).to eq DHC::Unauthorized
      expect(DHC::Error.find(response('402'))).to eq DHC::PaymentRequired
      expect(DHC::Error.find(response('403'))).to eq DHC::Forbidden
      expect(DHC::Error.find(response('403'))).to eq DHC::Forbidden
      expect(DHC::Error.find(response('404'))).to eq DHC::NotFound
      expect(DHC::Error.find(response('405'))).to eq DHC::MethodNotAllowed
      expect(DHC::Error.find(response('406'))).to eq DHC::NotAcceptable
      expect(DHC::Error.find(response('407'))).to eq DHC::ProxyAuthenticationRequired
      expect(DHC::Error.find(response('408'))).to eq DHC::RequestTimeout
      expect(DHC::Error.find(response('409'))).to eq DHC::Conflict
      expect(DHC::Error.find(response('410'))).to eq DHC::Gone
      expect(DHC::Error.find(response('411'))).to eq DHC::LengthRequired
      expect(DHC::Error.find(response('412'))).to eq DHC::PreconditionFailed
      expect(DHC::Error.find(response('413'))).to eq DHC::RequestEntityTooLarge
      expect(DHC::Error.find(response('414'))).to eq DHC::RequestUriToLong
      expect(DHC::Error.find(response('415'))).to eq DHC::UnsupportedMediaType
      expect(DHC::Error.find(response('416'))).to eq DHC::RequestedRangeNotSatisfiable
      expect(DHC::Error.find(response('417'))).to eq DHC::ExpectationFailed
      expect(DHC::Error.find(response('422'))).to eq DHC::UnprocessableEntity
      expect(DHC::Error.find(response('423'))).to eq DHC::Locked
      expect(DHC::Error.find(response('424'))).to eq DHC::FailedDependency
      expect(DHC::Error.find(response('426'))).to eq DHC::UpgradeRequired
      expect(DHC::Error.find(response('500'))).to eq DHC::InternalServerError
      expect(DHC::Error.find(response('501'))).to eq DHC::NotImplemented
      expect(DHC::Error.find(response('502'))).to eq DHC::BadGateway
      expect(DHC::Error.find(response('503'))).to eq DHC::ServiceUnavailable
      expect(DHC::Error.find(response('504'))).to eq DHC::GatewayTimeout
      expect(DHC::Error.find(response('505'))).to eq DHC::HttpVersionNotSupported
      expect(DHC::Error.find(response('507'))).to eq DHC::InsufficientStorage
      expect(DHC::Error.find(response('510'))).to eq DHC::NotExtended
    end

    it 'finds error class also by extended status codes' do
      expect(DHC::Error.find(response('40001'))).to eq DHC::BadRequest
      expect(DHC::Error.find(response('50002'))).to eq DHC::InternalServerError
    end

    it 'returns UnknownError if no specific error was found' do
      expect(DHC::Error.find(response('0'))).to eq DHC::UnknownError
      expect(DHC::Error.find(response(''))).to eq DHC::UnknownError
      expect(DHC::Error.find(response('600'))).to eq DHC::UnknownError
    end
  end
end
