# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'esapiserver/version'

Gem::Specification.new do |spec|
  spec.name          = "esapiserver"
  spec.version       = Esapiserver::VERSION
  spec.authors       = ["William Miles"]
  spec.email         = ["william@miles.dk"]
  spec.summary       = "Ember Sinatra API server"
  spec.description   = "A Sinatra/MongoDB API server to use for EmberJS development"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "pry-debugger"
  spec.add_development_dependency "rack-test"
  
  spec.add_runtime_dependency 'sinatra', '~> 1.4.5'
  spec.add_runtime_dependency 'mongo', '~> 1.10.2'
  spec.add_runtime_dependency 'bson_ext'
  spec.add_runtime_dependency 'json', '~> 1.8.1'
  spec.add_runtime_dependency 'sinatra-cross_origin', '~> 0.3.2'
  spec.add_runtime_dependency 'activesupport-inflector', '~> 0.1.0'
  spec.add_runtime_dependency 'i18n'
end
