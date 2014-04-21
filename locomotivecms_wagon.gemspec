require_relative 'lib/locomotive/wagon/version'

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
  gem.add_dependency 'thin',                  '~> 1.6'
  gem.add_dependency 'activesupport',         '~> 3.2'
  gem.add_dependency 'rubyzip',               '~> 1.1'
  gem.add_dependency 'better_errors',         '~> 1.1'
  gem.add_dependency 'listen',                '~> 2.7'
  gem.add_dependency 'faker',                 '~> 1.3'

  gem.add_dependency 'httmultiparty',         '0.3.10'

  gem.add_dependency 'locomotivecms_mounter', '~> 1.4.0'
  # gem.add_dependency 'locomotivecms_steam',  '~> 0.1.1'
  gem.add_dependency 'locomotivecms_common',  '~> 0.0.1'

  gem.add_development_dependency 'rake',      '~> 10.3'
  gem.add_development_dependency 'rspec',     '~> 2.14'
  gem.add_development_dependency 'vcr',       '~> 2.9'
  gem.add_development_dependency 'webmock',   '~> 1.17'
  gem.add_development_dependency 'rack-test', '~> 0.6'
  gem.add_development_dependency 'launchy',   '~> 2.4'
end
