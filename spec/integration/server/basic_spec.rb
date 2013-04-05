# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/server'
require 'rack/test'

describe Locomotive::Wagon::Server do

  include Rack::Test::Methods

  def app
    path = 'spec/fixtures/default'
    Locomotive::Wagon::Logger.setup(path, false)
    reader = Locomotive::Mounter::Reader::FileSystem.instance
    reader.run!(path: path)
    Locomotive::Wagon::Server.new(reader, disable_listen: true)
  end

  it 'shows the index page' do
    get '/index'
    last_response.body.should =~ /Upcoming events/
  end

  it 'shows the 404 page' do
    get '/void'
    last_response.body.should =~ /page not found/
  end

  it 'shows content' do
    get '/about-us/jane-doe'
    last_response.body.should =~ /Lorem ipsum dolor sit amet/
  end

  it 'shows a content type template ' do
    get '/songs/song-1'
    last_response.body.should =~ /Song #1/
  end

  it 'translates strings' do
    get '/en'
    last_response.body.should =~ /Powered by/
    get '/fr'
    last_response.body.should =~ /Propulsé par/
    get '/nb'
    last_response.body.should_not =~ /Powered by/
  end

end