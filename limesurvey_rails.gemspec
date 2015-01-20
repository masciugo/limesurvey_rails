# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'limesurvey_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "limesurvey_rails"
  spec.version       = LimesurveyRails::VERSION
  spec.authors       = ["masciugo"]
  spec.email         = ["masciugo@gmail.com"]
  spec.summary       = %q{An ORM-like layer to Limesurvey}
  spec.description   = %q{A limesurvey plugin for Rails to make an ActiveRecord model able to participate to Limesurvey surveys}
  spec.homepage      = "https://github.com/masciugo/limesurvey_rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rails', '~> 3.2', '>= 3.2.16'
  spec.add_runtime_dependency 'limesurvey', '~> 1.0'

  spec.add_development_dependency 'rspec-rails', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'factory_girl_rails', '~> 4'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'byebug', '~> 3.5'
end
