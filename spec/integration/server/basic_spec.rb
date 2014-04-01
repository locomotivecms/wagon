# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/steam/server'
require 'rack/test'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'shows the index page' do
    get '/index'
    last_response.body.should =~ /Upcoming events/
  end

  it 'shows the 404 page' do
    get '/void'
    last_response.status.should eq(404)
    last_response.body.should =~ /page not found/
  end

  it 'shows the 404 page with 200 status code when its called explicitly' do
    get '/404'
    last_response.status.should eq(200)
    last_response.body.should =~ /page not found/
  end

  it 'shows content' do
    get '/about-us/jane-doe'
    last_response.body.should =~ /Lorem ipsum dolor sit amet/
  end

  it 'shows a content type template ' do
    get '/songs/song-number-1'
    last_response.body.should =~ /Song #1/
  end

  it 'renders a page under a templatized one' do
    get '/songs/song-number-1/band'
    last_response.body.should =~ /Song #1/
    last_response.body.should =~ /Leader: Eddie/
  end

  it 'translates strings' do
    get '/en'
    last_response.body.should =~ /Powered by/
    get '/fr'
    last_response.body.should =~ /Propulsé par/
    get '/nb'
    last_response.body.should_not =~ /Powered by/
  end

  it 'provides translation in scopes' do
    get '/'
    last_response.body.should =~ /scoped_translation=.French./
  end

  it 'translates a page with link_to tags inside' do
    get '/fr/notre-musique'
    last_response.body.should =~ /<h3><a href="\/fr\/songs\/song-number-8">Song #8<\/a><\/h3>/
    last_response.body.should =~ /Propulsé par/
  end

  it 'returns all the pages' do
    get '/all'
    last_response.body.should =~ /Home page/
    last_response.body.should =~ /<li>Home page<\/li>/
    last_response.body.should =~ /<li>John-doe<\/li>/
    last_response.body.should =~ /<li>Songs<\/li>/
    last_response.body.should =~ /<li>A song template<\/li>/
  end

  describe 'snippets' do

    it 'includes a basic snippet' do
      get '/'
      last_response.body.should =~ /All photos are licensed under Creative Commons\./
    end

    it 'includes a snippet whose name is composed of dash' do
      get '/'
      last_response.body.should =~ /<p>A complicated one name indeed.<\/p>/
    end

  end

  describe 'nav' do

    subject { get '/all'; last_response.body }

    it { should_not match(/<nav id="nav">/) }

    it { should match(/<li id="about-us-link" class="link first"><a href="\/about-us">About Us<\/a><\/li>/) }

    it { should match(/<li id="music-link" class="link"><a href="\/music">Music<\/a><\/li>/) }

    it { should match(/<li id="store-link" class="link"><a href="\/store">Store<\/a><\/li>/) }

    it { should match(/<li id="contact-link" class="link last"><a href="\/contact">Contact Us<\/a><\/li>/) }

    it { should_not match(/<li id="events-link" class="link"><a href="\/events">Events<\/a><\/li>/) }

    describe 'with wrapper' do

      subject { get '/tags/nav'; last_response.body }

      it { should match(/<nav id="nav">/) }

    end

    describe 'very deep' do

      subject { get '/tags/nav_in_deep'; last_response.body }

      it { should match(/<li id=\"john-doe-link\" class=\"link first last\">/) }

    end

  end

  describe 'contents with_scope' do
    subject { get '/grunge_bands'; last_response.body }

    it { should match(/Layne/)}
    it { should_not match(/Peter/) }
  end

  describe "pages with_scope" do
    subject { get '/unlisted_pages'; last_response.body }
    it { subject.should match(/Page to test the nav tag/)}
    it { should_not match(/About Us/)}
  end

  describe 'theme assets' do

    subject { get '/all'; last_response.body }

    it { should match(/<link href="\/stylesheets\/application.css" media="screen" rel="stylesheet" type="text\/css" \/>/) }

    it { should match(/<script src="\/javascripts\/application.js" type='text\/javascript'><\/script>/) }

    it { should match(/<link rel="alternate" type="application\/atom\+xml" title="A title" href="\/foo\/bar" \/>/) }

  end

  describe 'session' do

    subject { get '/contest'; last_response.body }

    it { should match(/Your code is: HELLO WORLD/) }
    it { should_not match(/You've already participated to that contest ! Come back later./) }

    describe 'assign tag' do

      subject { 2.times { get '/contest' }; last_response.body }

      it { should_not match(/Your code is: HELLO WORLD/) }
      it { should match(/You've already participated to that contest ! Come back later./) }

    end

  end

end