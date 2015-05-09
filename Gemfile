source 'https://rubygems.org'

# Specify your gem's dependencies in wagon.gemspec
gemspec

# Development
# gem 'locomotivecms-liquid', path: '../gems/liquid', require: false
# gem 'locomotivecms-solid', path: '../gems/solid', require: false
# gem 'locomotivecms_mounter', path: '../gems/mounter', require: false
# gem 'locomotivecms_mounter', github: 'locomotivecms/mounter', ref: '6025c4a', require: false

gem 'rb-fsevent', '~> 0.9.1'

gem 'therubyracer'

# gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: 'b2de77e', require: false
# gem 'locomotivecms_coal', github: 'locomotivecms/coal', ref: '32b2844', require: false
# gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '3046b79893', require: false

gem 'locomotivecms_coal', path: '../in_progress/coal', require: false
gem 'locomotivecms_steam', path: '../in_progress/steam', require: false
gem 'locomotivecms_common', path: '../in_progress/common', require: false

group :test do
  gem 'rspec',              '~> 3.2.0'
  gem 'json_spec',          '~> 1.1.4'

  gem 'pry-byebug',         '~> 3.1.0'

  gem 'webmock'
  gem 'vcr'

  gem 'coveralls',                  '~> 0.7.11', require: false
end
