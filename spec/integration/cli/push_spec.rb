# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/cli'

describe Locomotive::Wagon::CLI do
  it "overrides subdomains and domains in different environments" do
    clone_site
    deploy = YAML.load_file('site/config/deploy.yml')
    deploy["staging"] = deploy["production"].merge("domains" => ["staging.example.com"], "subdomain" => "staging", "host" => "staging.example.com:3000")
    File.write('site/config/deploy.yml', deploy.to_yaml)
    VCR.use_cassette("staging") do
      Locomotive::Wagon::CLI::Main.start(['push', 'staging', 'site', '-f'])
    end

    WebMock.should_not have_requested(:put, /sites\/.+.json\?auth_token=.+/).with(body: /site\[subdomain\]=sample/)
    WebMock.should have_requested(:put, /sites\/.+.json\?auth_token=.+/).with(body: /site\[subdomain\]=staging&site\[domains\]\[\]=staging.example.com/).once
  end
end