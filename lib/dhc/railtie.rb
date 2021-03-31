# frozen_string_literal: true

module DHC
  class Railtie < Rails::Railtie
    initializer "dhc.configure_rails_initialization" do
      DHC::Caching.cache ||= Rails.cache
    end
  end
end
