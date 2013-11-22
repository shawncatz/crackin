# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crackin/version'

Gem::Specification.new do |spec|
  spec.name          = "crackin"
  spec.version       = Crackin::Version::STRING
  spec.authors       = ["Shawn Catanzarite"]
  spec.email         = ["me@shawncatz.com"]
  spec.description   = %q{release the crackin - gem release management}
  spec.summary       = %q{release the crackin - gem release management}
  spec.homepage      = "http://github.com/shawncatz/crackin"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'git'
  spec.add_dependency 'clamp'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
