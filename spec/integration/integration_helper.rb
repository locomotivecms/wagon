# encoding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'
require 'vcr'
require 'webmock/rspec'
require 'active_support/core_ext'

VCR.configure do |c|
  c.ignore_localhost = false
  c.cassette_library_dir = File.dirname(__FILE__) + '/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
end