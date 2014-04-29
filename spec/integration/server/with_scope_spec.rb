# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/server'
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

  it 'returns the right number of bands' do
    get '/filtered'
    last_response.body.should =~ /bands=2./
  end

  it 'returns the first band in the right order' do
    get '/filtered'
    last_response.body.should =~ /first event=Browne's Market/
  end

end