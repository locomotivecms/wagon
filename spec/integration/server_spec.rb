# encoding: utf-8
require File.dirname(__FILE__) + "/integration_helper"
require "locomotive/wagon/server"
require "rack/test"

describe Locomotive::Wagon::Server do
  include Rack::Test::Methods
  
  def app
    clone_site
    reader = Locomotive::Mounter::Reader::FileSystem.instance
    reader.run!(path: "site")
    Locomotive::Wagon::Server.new(reader)
  end
  
  it "shows the index page" do
    get '/'
    last_response.body.should =~ /Content of the home page/
  end
  
  it "shows the 404 page" do
    get '/void'
    last_response.body.should =~ /Content of the 404 page/
  end
  
  it "shows content" do
    get '/products/latest'
    last_response.body.should =~ /The name of the latest product is: Useless stuff/
  end
  
  it "translates strings" do
    get '/en/translated'
    last_response.body.should =~ /Hello world!/
    get '/es/translated'
    last_response.body.should =~ /¡Hola, Mundo!/
  end
end