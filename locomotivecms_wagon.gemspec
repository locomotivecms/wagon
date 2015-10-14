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

  gem.add_development_dependency 'rake',      '~> 10.0.4'

  gem.add_dependency 'thor',                  '~> 0.19.1'
  gem.add_dependency 'thin',                  '~> 1.6.3'
  gem.add_dependency 'rubyzip',               '~> 1.1.7'
  gem.add_dependency 'netrc',                 '~> 0.10.3'

  gem.add_dependency 'locomotivecms_coal',    '~> 1.0.0.rc1'
  gem.add_dependency 'locomotivecms_steam',   '~> 1.0.0.rc1'

  gem.add_dependency 'listen',                '~> 2.10.0'
  gem.add_dependency 'rack-livereload',       '~> 0.3.15'
  gem.add_dependency 'yui-compressor',        '~> 0.12.0'

  gem.add_dependency 'faker',                 '~> 1.4.3'
end
