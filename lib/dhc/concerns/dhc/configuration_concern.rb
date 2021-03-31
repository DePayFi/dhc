# frozen_string_literal: true

require 'active_support'

module DHC
  module ConfigurationConcern
    extend ActiveSupport::Concern

    module ClassMethods
      def config
        DHC::Config.instance
      end

      def configure
        DHC::Config.instance.reset
        yield config
      end
    end
  end
end
