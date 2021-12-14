# frozen_string_literal: true

class DHC::Error < StandardError
  include DHC::FixInvalidEncodingConcern

  attr_accessor :response, :_message

  def self.map
    {
      400 => DHC::BadRequest,
      401 => DHC::Unauthorized,
      402 => DHC::PaymentRequired,
      403 => DHC::Forbidden,
      404 => DHC::NotFound,
      405 => DHC::MethodNotAllowed,
      406 => DHC::NotAcceptable,
      407 => DHC::ProxyAuthenticationRequired,
      408 => DHC::RequestTimeout,
      409 => DHC::Conflict,
      410 => DHC::Gone,
      411 => DHC::LengthRequired,
      412 => DHC::PreconditionFailed,
      413 => DHC::RequestEntityTooLarge,
      414 => DHC::RequestUriToLong,
      415 => DHC::UnsupportedMediaType,
      416 => DHC::RequestedRangeNotSatisfiable,
      417 => DHC::ExpectationFailed,
      422 => DHC::UnprocessableEntity,
      423 => DHC::Locked,
      424 => DHC::FailedDependency,
      426 => DHC::UpgradeRequired,

      500 => DHC::InternalServerError,
      501 => DHC::NotImplemented,
      502 => DHC::BadGateway,
      503 => DHC::ServiceUnavailable,
      504 => DHC::GatewayTimeout,
      505 => DHC::HttpVersionNotSupported,
      507 => DHC::InsufficientStorage,
      510 => DHC::NotExtended
    }
  end

  def self.find(response)
    return DHC::Timeout if response.timeout?
    status_code = response.code.to_s[0..2].to_i
    error = map[status_code]
    error ||= DHC::UnknownError
    error
  end

  def self.dup
    self
  end

  def initialize(message, response)
    super(message)
    self._message = message
    self.response = response
  end

  def self.to_a
    [self]
  end

  def to_s
    return response.to_s unless response.is_a?(DHC::Response)
    request = response.request
    return unless request.is_a?(DHC::Request)

    debug = []
    debug << [request.method, request.url].map { |str| self.class.fix_invalid_encoding(str) }.join(' ')
    debug << "Response Code: #{response.code} (#{response.options[:return_code]})"
    debug << response.body
    debug << _message

    debug.map { |str| self.class.fix_invalid_encoding(str) }.join("\n")
  end
end
