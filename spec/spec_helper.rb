require 'rubygems'
require 'bundler/setup'

require 'launchy'
require 'coveralls'
require 'i18n'

require_relative '../lib/locomotive/wagon'
require_relative 'support'

Coveralls.wear!

RSpec.configure do |config|
  config.include Spec::Helpers

  config.filter_run focused: true
  config.run_all_when_everything_filtered = true

  config.before(:all) do
    I18n.enforce_available_locales = false
    remove_logs
  end

  config.before { reset! }

  config.after  { reset! }
end
