require 'webmock/rspec'
require 'vcr'

# VCR config
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.ignore_hosts 'codeclimate.com'
  c.configure_rspec_metadata!
end
