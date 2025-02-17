# frozen_string_literal: true

require 'active_support/core_ext/module'

# The response contains the raw response (typhoeus)
# and provides functionality to access response data.
class DHC::Response

  attr_accessor :request, :body_replacement
  attr_reader :from_cache

  delegate :effective_url, :code, :headers, :options, :mock, :success?, to: :raw
  delegate :error_ignored?, to: :request
  alias from_cache? from_cache

  # A response is initalized with the underlying raw response (typhoeus in our case)
  # and the associated request.
  def initialize(raw, request, from_cache: false)
    self.request = request
    self.raw = raw
    @from_cache = from_cache
  end

  def data
    @data ||= body.present? ? JSON.parse(body) : nil
  end

  def [](key)
    data[key]
  end

  def body
    body_replacement || raw.body.presence
  end

  # Provides response time in seconds
  def time
    raw.time || 0
  end

  # Provides response time in milliseconds
  def time_ms
    time * 1000
  end

  def timeout?
    raw.timed_out?
  end

  def format
    return DHC::Formats::JSON.new if request.nil?
    request.format
  end

  private

  attr_accessor :raw

end
