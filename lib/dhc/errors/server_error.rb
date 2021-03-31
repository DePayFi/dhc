# frozen_string_literal: true

class DHC::ServerError < DHC::Error
end

class DHC::InternalServerError < DHC::ServerError
end

class DHC::NotImplemented < DHC::ServerError
end

class DHC::BadGateway < DHC::ServerError
end

class DHC::ServiceUnavailable < DHC::ServerError
end

class DHC::GatewayTimeout < DHC::ServerError
end

class DHC::HttpVersionNotSupported < DHC::ServerError
end

class DHC::InsufficientStorage < DHC::ServerError
end

class DHC::NotExtended < DHC::ServerError
end
