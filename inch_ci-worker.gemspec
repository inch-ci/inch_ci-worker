# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inch_ci/worker/version'

Gem::Specification.new do |spec|
  spec.name          = "inch_ci-worker"
  spec.version       = InchCI::Worker::VERSION
  spec.authors       = ["René Föhring"]
  spec.email         = ["rf@bamaru.de"]
  spec.summary       = %q{Worker for the Inch CI project}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/inch-ci/inch_ci-worker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"

  spec.add_dependency "inch", "0.4.10"
  spec.add_dependency "repomen", ">= 0.2.0.rc1"
end
