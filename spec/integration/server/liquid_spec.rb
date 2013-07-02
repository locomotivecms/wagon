# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/server'
require 'rack/test'

describe Locomotive::Wagon::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  it "converts {{ page.templatized? }} => true on templatized page" do
    get '/songs/song-1'
    last_response.body.should =~ /templatized=.true./
  end

  it "converts {{ page.templatized? }} => false on regular page" do
    get '/index'
    last_response.body.should =~ /templatized=.false./
  end

  it "converts {{ page.listed? }} => true on listed page" do
    get '/music'
    last_response.body.should =~ /listed=.true./
  end

  it "provides an access to page's content_type collection" do
    get '/songs/song-1'
    last_response.body.should =~ /content_type_size=.8./
  end

  it "provides count alias on collections" do
    get '/songs/song-1'
    last_response.body.should =~ /content_type_count=.8./
  end

  describe '.link_to' do

    it "writes a link to a page" do
      get '/events'
      last_response.body.should =~ /Discover: <a href="\/music">Music<\/a>/
    end

    it "writes a link to a page with a custom label" do
      get '/events'
      last_response.body.should =~ /<a href="\/about-us">Who are we \?<\/a>/
    end

    it "writes a link to a templatized page" do
      get '/events'
      last_response.body.should =~ /<a href="\/songs\/song-1">Song #1<\/a>/
    end



  end
end