require "locomotive/wagon"
require "rspec"
require "launchy"
require 'pry'

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file
end

RSpec.configure do |c|
  c.include Spec::Helpers
  c.before(:all) { remove_logs }
  c.before { reset! }
  c.after  { reset! }
end