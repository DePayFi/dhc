# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    DHC::Caching.central = nil
    DHC::Config.instance.reset
  end
end
