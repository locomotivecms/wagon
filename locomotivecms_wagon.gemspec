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
  gem.summary       = %q{The LocomotiveCMS wagon is a site generator for the LocomotiveCMS engine powered by all the efficient and modern HTML development tools (SASS, Webpack, ...etc).}
  gem.homepage      = 'http://www.locomotivecms.com'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.executables   = ['wagon']

  gem.add_development_dependency 'rake',      '~> 10.0.4'

  gem.add_dependency 'thor',                  '~> 0.19.4'
  gem.add_dependency 'puma',                  '~> 3.12.1'
  gem.add_dependency 'netrc',                 '~> 0.11.0'
  gem.add_dependency 'oj',                    '~> 3.7.11'

  gem.add_dependency 'locomotivecms_common',  '~> 0.3.1'
  gem.add_dependency 'locomotivecms_coal',    '~> 1.6.0.rc1'
  gem.add_dependency 'locomotivecms_steam',   '~> 1.5.0.rc0'

  gem.add_dependency 'haml',                  '~> 4.0.7'
  gem.add_dependency 'listen',                '~> 3.1.5'
  gem.add_dependency 'neatjson',              '~> 0.8.4'

  gem.add_dependency 'faker',                 '~> 1.6'
end
