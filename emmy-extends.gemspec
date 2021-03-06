# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_extends/version'

Gem::Specification.new do |spec|
  spec.name          = "emmy-extends"
  spec.version       = EmmyExtends::VERSION
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]
  spec.summary       = %q{Emmy support em-http-request, thin, savon, mysql2 etc.}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["emmy-thin"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "emmy-machine", "~> 0.1"
  spec.add_dependency "emmy-http", "~> 0.1"

  spec.add_development_dependency "eventmachine", "~> 1.2.1"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
