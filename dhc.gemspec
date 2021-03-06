# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'dhc/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'dhc'
  s.version     = DHC::VERSION
  s.authors     = ['https://github.com/DePayFi/dhc/contributors']
  s.email       = ['engineering@depay.fi']
  s.homepage    = 'https://github.com/DePayFi/dhc'
  s.summary     = 'Advanced HTTP Client for Ruby, fueled with interceptors'
  s.description = 'DHC is an advanced HTTP client. Implementing basic http-communication enhancements like interceptors, exception handling, format handling, accessing response data, configuring endpoints and placeholders and fully compatible, RFC-compliant URL-template support.'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.requirements << 'Ruby >= 2.0.0'
  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency 'activesupport', '>= 5.2'
  s.add_dependency 'addressable'
  s.add_dependency 'typhoeus', '>= 0.11'

  s.add_development_dependency 'prometheus-client', '~> 0.7.1'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rails', '>= 5.2', '< 7'
  s.add_development_dependency 'redis'
  s.add_development_dependency 'rspec-rails', '>= 3.0.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'webmock'

  s.license = 'GPL-3.0'
end
