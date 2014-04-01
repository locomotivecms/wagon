# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/steam/server'
require 'rack/test'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  it "converts {{ page.templatized? }} => true on templatized page" do
    get '/songs/song-number-1'
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
    get '/songs/song-number-1'
    last_response.body.should =~ /content_type_size=.8./
  end

  it "provides count alias on collections" do
    get '/songs/song-number-1'
    last_response.body.should =~ /content_type_count=.8./
  end

  describe '.link_to' do

    it "writes a link to a page" do
      get '/events'
      last_response.body.should =~ /Discover: <a href="\/music">Music<\/a>/
    end

    it "writes a localized a link" do
      get '/events'
      last_response.body.should =~ /Plus à notre sujet: <a href="\/fr\/a-notre-sujet">Qui sommes nous \?<\/a>/
    end

    it "writes a link to a page with a custom label" do
      get '/events'
      last_response.body.should =~ /More about us: <a href="\/about-us">Who are we \?<\/a>/
    end

    it "writes a link to a templatized page" do
      get '/events'
      last_response.body.should =~ /<a href="\/songs\/song-number-1">Song #1<\/a>/
    end

    it "writes a link to a templatized page with a different handle" do
      get '/events'
      last_response.body.should =~ /<a href="\/songs\/song-number-8">Song #8<\/a>/
    end

  end

  describe 'scope & assigns' do

    it "evaluates collection when called all inside of scope" do
      get '/music'
      last_response.body.should =~ /<p class=.scoped_song.>Song #3/
      last_response.body.should =~ /<p class=.scoped_song_link.>\s+<a href=.\/songs\/song-number-3.>Song #3/m
    end

    it "size of evaluated unscoped collection equal to unevaluated one" do
      get '/music'
      last_response.body.should =~ /class=.collection_equality.>8=8/
    end

  end

  describe 'html helpers' do
    it 'bypass url for css resource' do
      get '/'
      last_response.body.should =~ /<link href=("|')http:\/\/fonts\.googleapis\.com\/css\?family=Open\+Sans:400,700("|')/
    end
  end

end