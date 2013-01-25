require File.dirname(__FILE__) + "/integration_helper"

describe Locomotive::Builder do
  it "imports" do
    File.exists?("site/config/site.yml").should be_false
    clone_site
    YAML.load_file("site/config/site.yml").should == {
      "name"=>"locomotive",
      "locales"=>["en", "es"],
      "subdomain"=>"locomotive",
      "domains"=>["locomotive.engine.dev"]
    }
  end
  
  it "pushes" do
    clone_site
    file_name = File.dirname(__FILE__) + '/../../site/app/views/pages/index.liquid'
    text = File.read(file_name)
    text.gsub!(/Content of the home page/, "New content of the home page")
    File.open(file_name, "w") { |file| file.puts text}
    VCR.use_cassette('push') do
      Locomotive::Builder.push("site", {"host" => "locomotive.engine.dev:3000"}, "email" => "admin@locomotivecms.com", "password" => "locomotive")
    end
    
    WebMock.should have_requested(:put, /pages\/.+.json\?auth_token=.+/).with(:body => /page\[raw_template\]=New%20content%20of%20the%20home%20page/).once
  end
end