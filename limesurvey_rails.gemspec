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
  spec.description   = %q{An ORM-like layer to Limesurvey}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency(%q<rails>, ["~> 3.2.16"])
  spec.add_runtime_dependency(%q<limesurvey>, [">= 0"])

  spec.add_development_dependency(%q<rspec-rails>, [">= 0"])
  spec.add_development_dependency(%q<rspec-its>, [">= 0"])
  spec.add_development_dependency(%q<factory_girl_rails>, [">= 0"])
  spec.add_development_dependency(%q<sqlite3>, [">= 0"])
  spec.add_development_dependency(%q<debugger>, [">= 0"])
  spec.add_development_dependency(%q<awesome_print>, [">= 0"])
end
