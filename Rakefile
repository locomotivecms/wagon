require "bundler/gem_tasks"
require "vcr"
require "locomotive/builder"

namespace :development do
  task :bootstrap do
    VCR.configure do |c|
      c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/spec/integration/cassettes')
      c.hook_into :webmock # or :fakeweb
      c.allow_http_connections_when_no_cassette = true
      # c.ignore_request do |request|
      #   URI(request.uri).path =~ /translations/
      # end
    end
    
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), 'site'))
    VCR.use_cassette('pull') do
      exit unless Locomotive::Builder.clone("site", {"host" => "http://locomotive.engine.dev:3000"}, "email" => "admin@locomotivecms.com", "password" => "locomotive")
    end
    
    Locomotive::Builder.push("site", {"host" => "http://locomotive.engine.dev:3000"}, "email" => "admin@locomotivecms.com", "password" => "locomotive", "force" => true, "data" => true)
  end
end
