ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'factory_girl_rails'

Rails.backtrace_cleaner.remove_silencers!

# This is done so that we can access it in our tests or RSpec configuration
ENGINE_RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

# add factories paths just to be sure 
FactoryGirl.definition_file_paths << Pathname.new(File.join(ENGINE_RAILS_ROOT,"spec/dummy/spec/factories"))
FactoryGirl.definition_file_paths << Pathname.new(File.join(ENGINE_RAILS_ROOT,"spec/factories"))
FactoryGirl.definition_file_paths.uniq!
FactoryGirl.reload

RSpec.configure do |config|
  config.use_transactional_examples = true # this rollback db after each example
  config.fail_fast = true
  config.order = "random"
  config.color = true
  config.formatter = :documentation
end

# http://stackoverflow.com/questions/4763983/comparing-activerecord-objects-with-rspec?rq=1
RSpec::Matchers.define :have_same_attributes_as do |expected|
  match do |actual|
    ignored = [:id, :updated_at, :created_at]
    actual.attributes.except(*ignored) == expected.attributes.except(*ignored)
  end
end

RSpec::Matchers.define :ar_eql do |expected|
  match do |actual|
    # puts 'custom eql'
    actual.class.name == expected.class.name and actual.id == expected.id
  end
end

RSpec::Matchers.define :match_ar_array do |expected|
  match do |actual|
    actual.sort_by!(&:id)
    expected.sort_by!(&:id)
    actual.map{|e| e.class.name } == expected.map{|e| e.class.name } and actual.map(&:id) == expected.map(&:id)
  end

  failure_message do |actual|
    <<-MSG
        expected collection classes contained: #{expected.map{|e| e.class.name }}
        actual collection classes contained: #{actual.map{|e| e.class.name }}
        expected collection ids contained: #{expected.map(&:id)}
        actual collection ids contained: #{actual.map(&:id)}
      MSG
  end

  failure_message_when_negated do |actual|
    <<-MSG
        expected collection classes contained: #{expected.map{|e| e.class.name }}
        actual collection classes contained: #{actual.map{|e| e.class.name }}
        expected collection ids contained: #{expected.map(&:id)}
        actual collection ids contained: #{actual.map(&:id)}
      MSG
  end

  description do
    "contains same AR objects as #{expected}"
  end

end


