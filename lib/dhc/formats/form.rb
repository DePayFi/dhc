# frozen_string_literal: true

module DHC::Formats
  class Form < DHC::Format
    include DHC::BasicMethodsConcern

    def self.request(options)
      options[:format] = new
      super(options)
    end

    def format_options(options)
      options[:headers] ||= {}
      no_content_type_header!(options)
      options[:headers]['Content-Type'] = 'application/x-www-form-urlencoded'
      options
    end

    def as_json(input)
      parse(input)
    end

    def as_open_struct(input)
      parse(input)
    end

    def to_body(input)
      input
    end

    def to_s
      'form'
    end

    def to_sym
      to_s.to_sym
    end

    private

    def parse(input)
      input
    end
  end
end
