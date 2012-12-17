require File.dirname(__FILE__) + "/integration_helper"
require "locomotive/builder/server"
require "rack/test"

describe Locomotive::Builder::Server do
  include Rack::Test::Methods
  
  def app
    import_site
    reader = Locomotive::Mounter::Reader::FileSystem.instance
    reader.run!(path: "site")
    Locomotive::Builder::Server.new(reader)
  end
  
  it "shows the index page" do
    get '/'
    last_response.body.should =~ /Content of the home page/
  end
  
  it "shows the 404 page" do
    get '/void'
    last_response.body.should =~ /Content of the 404 page/
  end
end