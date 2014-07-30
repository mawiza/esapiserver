require 'pry'
require 'esapiserver'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Esapiserver::Server end
end

RSpec.configure do |config|  
  config.include Rack::Test::Methods
  config.include RSpecMixin
end