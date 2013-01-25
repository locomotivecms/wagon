require File.dirname(__FILE__) + "/integration_helper"

describe Locomotive::Builder do
  it "imports" do
    File.exists?("site/config/site.yml").should be_false
    import_site
    YAML.load_file("site/config/site.yml").should == {
      "name"=>"locomotive",
      "locales"=>["en"],
      "subdomain"=>"locomotive",
      "domains"=>["locomotive.engine.dev"]
    }
  end
end