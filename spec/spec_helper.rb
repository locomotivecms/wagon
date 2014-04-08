require "locomotive/wagon"
require "rspec"
require "launchy"
require 'coveralls'
require 'pry'
Coveralls.wear!

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file
end

RSpec.configure do |config|
  config.include Spec::Helpers
  config.before(:all) { remove_logs }
  config.before { reset! }
  config.after  { reset! }
  config.filter_run focused: true
  config.run_all_when_everything_filtered = true

end