require 'bundler/setup'
require 'rack/test'
require 'rspec'
require 'rspec/its'
require 'vcr'
require 'timecop'
require 'pry'

require_relative '../app.rb'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |c|
  c.include RSpecMixin
end

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../fixtures/vcr', __FILE__ )
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
