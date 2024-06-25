source 'https://rubygems.org'

# Specify your gem's dependencies in locomotivecms_wagon.gemspec
gemspec

# Mac OS X
gem 'rb-fsevent', '~> 0.10.3', require: 'rb-fsevent' if RUBY_PLATFORM.include?('darwin')

# Unix
gem 'therubyracer', require: 'v8', platforms: :ruby unless RUBY_PLATFORM.include?('darwin')

gem 'rb-inotify', '~> 0.10.0', require: 'rb-inotify' if RUBY_PLATFORM.include?('linux')

# Windows
gem 'wdm', '~> 0.1.1', require: 'wdm' if RUBY_PLATFORM =~ /mswin|mingw/i

# Development
# gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '054505c' , require: false
# gem 'locomotivecms_coal',   github: 'locomotivecms/coal',   ref: '3c5f8f8', require: false
# gem 'locomotivecms_steam',  github: 'locomotivecms/steam',  ref: '67c0de7b4e', require: false
# gem 'duktape', github: 'judofyr/duktape.rb', ref: '20ef6a5'

# Local development
# gem 'locomotivecms_coal', path: '../coal', require: false
# gem 'locomotivecms_steam', path: '../steam', require: false
# gem 'locomotivecms_common', path: '../common', require: false

group :development, :test do
  gem 'pry-byebug',         '~> 3.10.1'
end

group :test do
  gem 'rspec',              '~> 3.12.0'
  gem 'json_spec',          '~> 1.1.5'
  gem 'vcr',                '~> 6.2.0'

  # gem 'codeclimate-test-reporter',  '~> 1.0.7',  require: false
  # gem 'coveralls',                  '~> 0.8.19', require: false
  gem 'simplecov',                  '~> 0.22.0', require: false
end
