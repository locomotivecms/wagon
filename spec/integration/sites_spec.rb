require File.dirname(__FILE__) + "/integration_helper"

describe Locomotive::Builder do
  it "imports" do
    File.exists?("site/config/site.yml").should be_false
    pull_site
    YAML.load_file("site/config/site.yml").should == {
      "name"=>"locomotive",
      "locales"=>["en", "es"],
      "subdomain"=>"locomotive",
      "domains"=>["locomotive.engine.dev"],
      "seo_title"=>{"en"=>nil, "es"=>nil},
      "meta_keywords"=>{"en"=>nil, "es"=>nil},
      "meta_description"=>{"en"=>nil, "es"=>nil}
    }
  end
  
  it "pushes" do
    pull_site
    file_name = File.dirname(__FILE__) + '/../../site/app/views/pages/index.liquid'
    text = File.read(file_name)
    text.gsub!(/Content of the home page/, "New content of the home page")
    File.open(file_name, "w") { |file| file.puts text}
    VCR.use_cassette('push') do
      Locomotive::Builder.push("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
    end
    
    WebMock.should have_requested(:put, /pages\/.+.json\?auth_token=.+/).with(:body => /page\[raw_template\]=New%20content%20of%20the%20home%20page/).once
  end
end