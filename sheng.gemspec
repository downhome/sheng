# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sheng/version'

Gem::Specification.new do |spec|
  spec.name          = "sheng"
  spec.version       = Sheng::VERSION
  spec.authors       = ["Ravi Gadad", "Maher Hawash"]
  spec.email         = ["ravi@renewfund.com"]
  spec.description   = "A Ruby gem for data merging Word documents."
  spec.summary       = "A Ruby gem for data merging Word documents, using native MergeFields as placeholders in templates, and a Ruby hash as the data set for substitution."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "equivalent-xml", ">= 0.6"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "nokogiri", "~> 1.6"
  spec.add_dependency "rubyzip", "~> 1.1.1"
  spec.add_dependency "activesupport", "~> 4.0"
  spec.add_dependency "dentaku", "~> 2.0"
end
