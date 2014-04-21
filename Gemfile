source 'https://rubygems.org'

# Specify your gem's dependencies in wagon.gemspec
gemspec

group :development do
  # gem 'locomotivecms_common',  path: '../common',  require: false
  # gem 'locomotivecms_mounter', path: '../mounter', require: false
  # gem 'locomotivecms_steam',   path: '../steam',   require: false
end

group :test do
  gem 'pry'
  gem 'coveralls', require: false
end

platform :jruby do
  ruby '1.9.3', engine: 'jruby', engine_version: '1.7.11'
end

platform :ruby do
  ruby '2.1.1'
end
