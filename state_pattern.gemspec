# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'state_pattern/version'

Gem::Specification.new do |spec|
  spec.name          = 'state_pattern'
  spec.version       = StatePattern::VERSION
  spec.author        = 'Dwayne R. Crooks'
  spec.email         = ['me@dwaynecrooks.com']
  spec.summary       = %q{An implementation of the State Design Pattern in Ruby.}
  spec.description   = %q{An implementation of the State Design Pattern in Ruby.}
  spec.homepage      = 'https://github.com/dwayne/state_pattern'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'minitest', '~> 5.3'
  spec.add_development_dependency 'coveralls', '~> 0.7'
end
