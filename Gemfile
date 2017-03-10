source 'https://rubygems.org'

# Specify your gem's dependencies in wagon.gemspec
gemspec

gem 'rb-fsevent', '~> 0.9.1'

# Development
# gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '257047b', require: false
# gem 'locomotivecms_coal',   github: 'locomotivecms/coal',   ref: 'f4ff435', require: false
# gem 'locomotivecms_steam',  github: 'locomotivecms/steam',  ref: 'b1feb8b', require: false
# gem 'duktape', github: 'judofyr/duktape.rb', ref: '20ef6a5'

# Local development
# gem 'locomotivecms_coal', path: '../gems/coal', require: false
# gem 'locomotivecms_steam', path: '../gems/steam', require: false
# gem 'locomotivecms_common', path: '../gems/common', require: false

group :development, :test do
  gem 'pry-byebug',         '~> 3.4.2'
end

group :test do
  gem 'rspec',              '~> 3.5.0'
  gem 'json_spec',          '~> 1.1.4'

  gem 'webmock'
  gem 'vcr'

  gem 'simplecov'
  gem 'codeclimate-test-reporter',  '~> 1.0.7',  require: false
  gem 'coveralls',                  '~> 0.8.19', require: false
end
