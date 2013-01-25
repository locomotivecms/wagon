require File.dirname(__FILE__) + '/../spec_helper'
require 'vcr'

VCR.configure do |c|
  c.ignore_localhost = false
  c.cassette_library_dir = File.dirname(__FILE__) + '/cassettes'
  c.hook_into :fakeweb
  c.default_cassette_options = { record: :new_episodes }
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end