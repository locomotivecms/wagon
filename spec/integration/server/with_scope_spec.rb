# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/steam/server'
require 'rack/test'

describe 'Complex with_scope conditions' do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'returns the right number of events' do
    get '/filtered'
    last_response.body.should =~ /events=1./
  end

end