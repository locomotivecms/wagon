# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locomotive/builder/version'

Gem::Specification.new do |gem|
  gem.name          = "locomotivecms_builder"
  gem.version       = Locomotive::Builder::VERSION
  gem.authors       = ["Rodrigo Alvarez"]
  gem.email         = ["papipo@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.executables   = ["builder"]
  
  gem.add_dependency "thor"
  gem.add_dependency "thin"
  # gem.add_dependency "locomotivecms_mounter" # remove from Gemfile before adding it here
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock", "~> 1.8.0"
  gem.add_development_dependency "rack-test"
end
