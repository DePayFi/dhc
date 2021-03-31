# frozen_string_literal: true

class DHC::ClientError < DHC::Error
end

class DHC::BadRequest < DHC::ClientError
end

class DHC::Unauthorized < DHC::ClientError
end

class DHC::PaymentRequired < DHC::ClientError
end

class DHC::Forbidden < DHC::ClientError
end

class DHC::Forbidden < DHC::ClientError
end

class DHC::NotFound < DHC::ClientError
end

class DHC::MethodNotAllowed < DHC::ClientError
end

class DHC::NotAcceptable < DHC::ClientError
end

class DHC::ProxyAuthenticationRequired < DHC::ClientError
end

class DHC::RequestTimeout < DHC::ClientError
end

class DHC::Conflict < DHC::ClientError
end

class DHC::Gone < DHC::ClientError
end

class DHC::LengthRequired < DHC::ClientError
end

class DHC::PreconditionFailed < DHC::ClientError
end

class DHC::RequestEntityTooLarge < DHC::ClientError
end

class DHC::RequestUriToLong < DHC::ClientError
end

class DHC::UnsupportedMediaType < DHC::ClientError
end

class DHC::RequestedRangeNotSatisfiable < DHC::ClientError
end

class DHC::ExpectationFailed < DHC::ClientError
end

class DHC::UnprocessableEntity < DHC::ClientError
end

class DHC::Locked < DHC::ClientError
end

class DHC::FailedDependency < DHC::ClientError
end

class DHC::UpgradeRequired < DHC::ClientError
end
