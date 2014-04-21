source 'https://rubygems.org'

# Specify your gem's dependencies in wagon.gemspec
gemspec

# Development
# gem 'locomotivecms-liquid', path: '../gems/liquid', require: false
# gem 'locomotivecms-solid', path: '../gems/solid', require: false
# gem 'locomotivecms_mounter', path: '../gems/mounter', require: false
# gem 'locomotivecms_mounter', github: 'locomotivecms/mounter', ref: '34d24feeb8', require: false
# gem 'locomotivecms_common', path: '../gems/common/', require: false
# gem 'locomotivecms_steam', path: '../gems/steam/' require: false

group :development do
  gem 'locomotivecms_common', '~> 0.0.1', path: '../common'
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
