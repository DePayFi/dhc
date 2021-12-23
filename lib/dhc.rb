# frozen_string_literal: true

require 'typhoeus'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'

module DHC
  autoload :BasicMethodsConcern, 'dhc/concerns/dhc/basic_methods_concern'
  autoload :ConfigurationConcern, 'dhc/concerns/dhc/configuration_concern'
  autoload :FixInvalidEncodingConcern, 'dhc/concerns/dhc/fix_invalid_encoding_concern'
  autoload :FormatsConcern, 'dhc/concerns/dhc/formats_concern'

  include BasicMethodsConcern
  include ConfigurationConcern
  include FormatsConcern

  autoload :Auth, 'dhc/interceptors/auth'
  autoload :Caching, 'dhc/interceptors/caching'
  autoload :DefaultTimeout, 'dhc/interceptors/default_timeout'
  autoload :Logging, 'dhc/interceptors/logging'
  autoload :Prometheus, 'dhc/interceptors/prometheus'
  autoload :Retry, 'dhc/interceptors/retry'
  autoload :Throttle, 'dhc/interceptors/throttle'

  autoload :Config, 'dhc/config'
  autoload :Endpoint, 'dhc/endpoint'

  autoload :Error, 'dhc/error'
  autoload :ClientError, 'dhc/errors/client_error'
  autoload :BadRequest, 'dhc/errors/client_error'
  autoload :Unauthorized, 'dhc/errors/client_error'
  autoload :PaymentRequired, 'dhc/errors/client_error'
  autoload :Forbidden, 'dhc/errors/client_error'
  autoload :Forbidden, 'dhc/errors/client_error'
  autoload :NotFound, 'dhc/errors/client_error'
  autoload :MethodNotAllowed, 'dhc/errors/client_error'
  autoload :NotAcceptable, 'dhc/errors/client_error'
  autoload :ProxyAuthenticationRequired, 'dhc/errors/client_error'
  autoload :RequestTimeout, 'dhc/errors/client_error'
  autoload :Conflict, 'dhc/errors/client_error'
  autoload :Gone, 'dhc/errors/client_error'
  autoload :LengthRequired, 'dhc/errors/client_error'
  autoload :PreconditionFailed, 'dhc/errors/client_error'
  autoload :RequestEntityTooLarge, 'dhc/errors/client_error'
  autoload :RequestUriToLong, 'dhc/errors/client_error'
  autoload :UnsupportedMediaType, 'dhc/errors/client_error'
  autoload :RequestedRangeNotSatisfiable, 'dhc/errors/client_error'
  autoload :ExpectationFailed, 'dhc/errors/client_error'
  autoload :UnprocessableEntity, 'dhc/errors/client_error'
  autoload :Locked, 'dhc/errors/client_error'
  autoload :FailedDependency, 'dhc/errors/client_error'
  autoload :UpgradeRequired, 'dhc/errors/client_error'
  autoload :ParserError, 'dhc/errors/parser_error'
  autoload :ServerError, 'dhc/errors/server_error'
  autoload :InternalServerError, 'dhc/errors/server_error'
  autoload :NotImplemented, 'dhc/errors/server_error'
  autoload :BadGateway, 'dhc/errors/server_error'
  autoload :ServiceUnavailable, 'dhc/errors/server_error'
  autoload :GatewayTimeout, 'dhc/errors/server_error'
  autoload :HttpVersionNotSupported, 'dhc/errors/server_error'
  autoload :InsufficientStorage, 'dhc/errors/server_error'
  autoload :NotExtended, 'dhc/errors/server_error'
  autoload :Timeout, 'dhc/errors/timeout'
  autoload :UnknownError, 'dhc/errors/unknown_error'

  autoload :Interceptor, 'dhc/interceptor'
  autoload :Interceptors, 'dhc/interceptors'
  autoload :Formats, 'dhc/formats'
  autoload :Format, 'dhc/format'
  autoload :Monitoring, 'dhc/interceptors/monitoring'
  autoload :Request, 'dhc/request'
  autoload :Response, 'dhc/response'
  autoload :Rollbar, 'dhc/interceptors/rollbar'
  autoload :Zipkin, 'dhc/interceptors/zipkin'
  autoload :Logger, 'dhc/logger'

  require 'dhc/railtie' if defined?(Rails)
end
