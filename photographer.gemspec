# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'photographer/version'

Gem::Specification.new do |spec|
  spec.name          = "photographer"
  spec.version       = Photographer::VERSION
  spec.authors       = ["Juliusz Gonera"]
  spec.email         = ["jgonera@gmail.com"]
  spec.summary       = %q{Framework-agnostic visual regression testing for web applications.}
  spec.description   = %q{Test for visual regressions using your existing testing stack.}
  spec.homepage      = "https://github.com/jgonera/photographer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "oily_png"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"
end
