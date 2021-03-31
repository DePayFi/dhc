# frozen_string_literal: true

module DHC
  module FormatsConcern
    extend ActiveSupport::Concern

    module ClassMethods
      def form
        DHC::Formats::Form
      end

      def json
        DHC::Formats::JSON
      end

      def multipart
        DHC::Formats::Multipart
      end

      def plain
        DHC::Formats::Plain
      end
    end
  end
end
