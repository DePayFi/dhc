# frozen_string_literal: true

require 'dhc'

RSpec.configure do |config|
  config.before(:each) do
    DHC::Caching.cache = ActiveSupport::Cache::MemoryStore.new
    DHC::Caching.cache.clear
    DHC::Throttle.track = nil
  end
end
