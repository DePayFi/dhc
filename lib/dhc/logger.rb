# frozen_string_literal: true

require 'singleton'
require 'forwardable'

class DHC::Logger < Logger
  include ActiveSupport::Configurable
  include Singleton

  config_accessor :logger

  class << self
    extend Forwardable
    def_delegators :instance, :log, :info, :error, :warn, :debug
  end

  def initialize
    if DHC::Logger.logger
      self.logger = DHC::Logger.logger
    elsif defined? Rails
      self.logger = Rails.logger
    end
  end

  def self.log(severity, message = nil, progname = nil)
    return if self.logger.blank?
    self.logger.log(severity, message, progname)
  end
end
