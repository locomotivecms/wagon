# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locomotive/wagon/version'

Gem::Specification.new do |gem|
  gem.name          = 'locomotivecms_wagon'
  gem.version       = Locomotive::Wagon::VERSION
  gem.authors       = ['Didier Lafforgue', 'Rodrigo Alvarez']
  gem.email         = ['did@locomotivecms.com', 'papipo@gmail.com']
  gem.description   = %q{Wagon is a site generator for the LocomotiveCMS engine}
  gem.summary       = %q{Wagon is a site generator for the LocomotiveCMS engine powered by all the efficient and modern HTML development tools (SASS, Webpack, ...etc).}
  gem.homepage      = 'https://www.locomotivecms.com'
  gem.license       = 'MIT'

  gem.files         = Dir['bin/*'] +
                      Dir.glob('generators/**/*', File::FNM_DOTMATCH) +
                      Dir['lib/**/*.rb'] +
                      %w(locomotivecms_wagon.gemspec MIT-LICENSE README.md)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.executables   = ['wagon']

  gem.add_development_dependency 'rake',      '~> 13.0.1'

  gem.add_dependency 'thor',                  '~> 0.20.3'
  gem.add_dependency 'puma',                  '~> 4.3.0'
  gem.add_dependency 'netrc',                 '~> 0.11.0'
  gem.add_dependency 'oj',                    '~> 3.9.2'

  gem.add_dependency 'locomotivecms_common',  '~> 0.4.0'
  gem.add_dependency 'locomotivecms_coal',    '~> 1.6.0'
  gem.add_dependency 'locomotivecms_steam',   '~> 1.5.1'

  gem.add_dependency 'haml',                  '~> 5.1.2'
  gem.add_dependency 'listen',                '~> 3.1.5'
  gem.add_dependency 'neatjson',              '~> 0.8.4'

  gem.add_dependency 'faker',                 '~> 1.6'
end
