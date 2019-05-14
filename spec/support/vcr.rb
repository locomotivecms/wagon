require 'vcr'
require 'faraday'

# VCR config
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :faraday
  c.ignore_hosts 'codeclimate.com'
  c.configure_rspec_metadata!
  c.debug_logger = $stdout
  c.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' ||
    !http_message.body.valid_encoding?
  end
end

# Without this, VCR is unable to match a POST request with uploaded files
# https://github.com/lostisland/faraday/issues/772
Faraday.default_connection_options.request.boundary = "------------------RubyMultiPartPost".freeze
