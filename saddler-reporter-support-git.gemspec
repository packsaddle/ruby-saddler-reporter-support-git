# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'saddler/reporter/support/git/version'

Gem::Specification.new do |spec|
  spec.name          = 'saddler-reporter-support-git'
  spec.version       = Saddler::Reporter::Support::Git::VERSION
  spec.authors       = ['sanemat']
  spec.email         = ['o.gata.ken@gmail.com']

  spec.summary       = 'Utilities for Saddler reporter and git repository.'
  spec.description   = 'Utilities for Saddler reporter and git repository.'
  spec.homepage      = 'https://github.com/packsaddle/ruby-saddler-reporter-support-git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'git'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'mocha'
end
