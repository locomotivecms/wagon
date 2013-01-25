require "locomotive/builder"
require "rspec"

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file
end

RSpec.configure do |c|
  c.include Spec::Helpers
  c.before { reset! }
  c.after  { reset! }
end