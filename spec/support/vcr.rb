require 'vcr'
require 'faraday'

# custom_body_matcher = lambda do |request_1, request_2|
#   puts request_1.body

#   raise 'TODO'

#   # URI(request_1.uri).port == URI(request_2.uri).port
# end

# # VCR.use_cassette('example', :match_requests_on => [:method, port_matcher]) do
# #   puts "Response for port 8000: " + response_body_for(:get, "http://example.com:8000/")
# # end

# VCR config
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :faraday
  c.ignore_hosts 'codeclimate.com'
  c.configure_rspec_metadata!
  c.debug_logger = $stdout
  # c.preserve_exact_body_bytes true

  #  do |http_message|
  #   puts "Grrrrr"
  #   if http_message.body.encoding.name == 'ASCII-8BIT'
  #     puts "~~~~~~~~ TEST ~~~~~~~~~~"
  #     puts http_message.body.inspect
  #   end
  #   # http_message.body.encoding.name == 'ASCII-8BIT' ||
  #   # !http_message.body.valid_encoding?
  #   false
  # end
end

# Without this, VCR is unable to match a POST request with uploaded files
# https://github.com/lostisland/faraday/issues/772
Faraday.default_connection_options.request.boundary = "------------------RubyMultiPartPost".freeze
