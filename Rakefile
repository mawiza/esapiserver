require 'rspec/core/rake_task'
require "bundler/gem_tasks"

def run(cmd, msg)
  `#{cmd}`
  if $?.exitstatus != 0
    puts msg
    exit 1
  end
end

desc "run sinatra app locally"
task :run do
  require 'esapiserver'
  #Sinatra::Application.run!
  Esapiserver::Server.run!
end

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'nested']
end

task :default => :spec