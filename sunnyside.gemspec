# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunnyside/version'

Gem::Specification.new do |spec|
  spec.name          = "sunnyside"
  spec.version       = Sunnyside::VERSION
  spec.authors       = ["wismer"]
  spec.email         = ["matthewhl@gmail.com"]
  spec.description   = "gem for Sunnyside Citywide Home Care, Inc."
  spec.summary       = "EDI/PDF parser, fiscal tools for accounting"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"]
  spec.executables   << 'sunnyside'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sequel"
  spec.add_development_dependency "money"
  spec.add_development_dependency "prawn"
end
