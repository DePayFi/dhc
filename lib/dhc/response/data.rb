# frozen_string_literal: true

class DHC::Response::Data
  autoload :Base, 'dhc/response/data/base'
  autoload :Item, 'dhc/response/data/item'
  autoload :Collection, 'dhc/response/data/collection'

  include DHC::Response::Data::Base

  def initialize(response, data: nil)
    @response = response
    @data = data

    if as_json.is_a?(Hash)
      @base = DHC::Response::Data::Item.new(@response, data: data)
    elsif as_json.is_a?(Array)
      @base = DHC::Response::Data::Collection.new(@response, data: data)
    end
  end

  def method_missing(method, *args, &block)
    @base.send(method, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    @base.respond_to?(method_name, include_private) || super
  end
end
