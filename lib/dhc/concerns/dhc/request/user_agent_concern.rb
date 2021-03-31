# frozen_string_literal: true

require 'active_support'
require 'dhc/version'

module DHC
  class Request
    module UserAgentConcern
      extend ActiveSupport::Concern

      included do
        Typhoeus::Config.user_agent = begin
          version = DHC::VERSION
          application = nil
          if defined?(Rails)
            app_class = Rails.application.class
            application = (ActiveSupport.gem_version >= Gem::Version.new('6.0.0')) ? app_class.module_parent_name : app_class.parent_name
          end

          "DHC (#{[version, application].compact.join('; ')}) [https://github.com/DePayFi/dhc]"
        end
      end
    end
  end
end
