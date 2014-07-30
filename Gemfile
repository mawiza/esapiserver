source 'https://rubygems.org'

# Specify your gem's dependencies in esapiserver.gemspec
gemspec

require 'rbconfig'
if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
  gem 'wdm', '>= 0.1.0'
end