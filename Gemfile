source 'https://rubygems.org'

# Specify your gem's dependencies in wagon.gemspec
gemspec

gem 'rb-fsevent', '~> 0.9.1'

gem 'therubyracer'

# Development
# gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: '0aa777b', require: false
# gem 'locomotivecms_coal', github: 'locomotivecms/coal', ref: '32b2844', require: false
# gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '3046b79893', require: false

# Local development
# gem 'locomotivecms_coal', path: '../gems/coal', require: false
gem 'locomotivecms_steam', path: '../gems/steam', require: false
# gem 'locomotivecms_common', path: '../in_progress/common', require: false

group :development, :test do
  gem 'pry-byebug',         '~> 3.1.0'
end

group :test do
  gem 'rspec',              '~> 3.2.0'
  gem 'json_spec',          '~> 1.1.4'

  gem 'webmock'
  gem 'vcr'

  gem 'coveralls',                  '~> 0.7.11', require: false
end
