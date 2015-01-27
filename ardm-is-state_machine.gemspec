# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dm-is-state_machine/is/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'ardm-is-state_machine'
  gem.version       = DataMapper::Is::StateMachine::VERSION

  gem.authors     = [ 'Martin Emde', 'David James' ]
  gem.email       = [ 'me@martinemde.com', 'djwonk [a] collectiveinsight [d] net' ]
  gem.summary     = 'Ardm fork of dm-is-state_machine'
  gem.description = 'DataMapper plugin for creating state machines'
  gem.homepage    = "https://github.com/ar-dm/ardm-is-state_machine"
  gem.license     = 'MIT'

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.rdoc]
  gem.require_paths = [ "lib" ]

  gem.add_runtime_dependency 'ardm-core', '~> 1.2'

  gem.add_development_dependency 'rake',  '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 1.3'
end
