# tasks for gem managment by bundler:
# rake build    # Build limesurvey_rails-1.1.0.gem into the pkg directory
# rake install  # Build and install limesurvey_rails-1.1.0.gem into system gems
# rake release  # Create tag v1.1.0 and build and push limesurvey_rails-1.1.0.gem to Rubygems
require "bundler/gem_tasks"

# check for missing gems
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

ENV["dummy_app_name"] = "dummy_rails_#{Bundler.load.specs.find{|g| g.name == 'rails'}.version.to_s.split('.').first}"

# load tasks from dummy application
APP_RAKEFILE = File.expand_path("../spec/#{ENV["dummy_app_name"]}/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

###### RSpec stuff 
require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run all specs in spec directory (excluding plugin specs) or the ones tagged by provided tag"
RSpec::Core::RakeTask.new(:spec, :tag, :seed) do |t, task_args|
  Rake::Task['app:db:test:prepare'].invoke
  t.rspec_opts = ''
  t.rspec_opts += " --tag #{task_args[:tag]}" unless task_args[:tag].blank?
  t.rspec_opts += " --seed #{task_args[:seed]}" unless task_args[:seed].blank?
end

desc "Run specfiles specified by pattern with optional seed"
RSpec::Core::RakeTask.new(:specfile, :pattern, :seed) do |t, task_args|
  Rake::Task['app:db:test:prepare'].invoke
  t.pattern = task_args[:pattern] unless task_args[:pattern].nil?
  t.rspec_opts = ''
  t.rspec_opts += " --seed #{task_args[:seed]}" unless task_args[:seed].blank?
  # t.rspec_opts += " --fail-fast" # Making RSpec stop operation immediately after failing
end
###### end of RSpec stuff

task :default => :spec
