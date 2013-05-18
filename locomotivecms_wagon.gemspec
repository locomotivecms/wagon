# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locomotive/wagon/version'

Gem::Specification.new do |gem|
  gem.name          = 'locomotivecms_wagon'
  gem.version       = Locomotive::Wagon::VERSION
  gem.authors       = ['Didier Lafforgue', 'Rodrigo Alvarez']
  gem.email         = ['did@locomotivecms.com', 'papipo@gmail.com']
  gem.description   = %q{The LocomotiveCMS wagon is a site generator for the LocomotiveCMS engine}
  gem.summary       = %q{The LocomotiveCMS wagon is a site generator for the LocomotiveCMS engine powered by all the efficient and modern HTML development tools (Haml, SASS, Compass, Less).}
  gem.homepage      = 'http://www.locomotivecms.com'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.executables   = ['wagon']

  gem.add_dependency 'thor'
  gem.add_dependency 'thin'
  gem.add_dependency 'activesupport',         '~> 3.2.11'
  gem.add_dependency 'locomotive_liquid',     '~> 2.4.1'
  gem.add_dependency 'RedCloth',              '~> 4.2.9'
  gem.add_dependency 'dragonfly',             '~> 0.9.12'
  gem.add_dependency 'rack-cache',            '~> 1.1'
  gem.add_dependency 'better_errors',         '~> 0.7.2'

  gem.add_dependency 'listen',                '~> 0.7.0'

  gem.add_dependency 'httmultiparty',         '0.3.8'
  gem.add_dependency 'will_paginate',         '~> 3.0.3'
  gem.add_dependency 'locomotivecms_mounter', '1.0.4'

  gem.add_dependency 'faker',                 '~> 0.9.5'

  gem.add_development_dependency 'rake',      '~> 10.0.4'
  gem.add_development_dependency 'rspec',     '~> 2.6.0'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'webmock',   '~> 1.8.0'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'launchy'
end
