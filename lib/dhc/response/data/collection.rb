# frozen_string_literal: true

class DHC::Response::Data::Collection < Array
  include DHC::Response::Data::Base

  def initialize(response, data: nil)
    @response = response
    @data = data

    super(
      as_json.map do |i|
        DHC::Response::Data.new(response, data: i)
      end
    )
  end
end
