require "bundler/gem_tasks"
require "vcr"
require "locomotive/builder"

namespace :development do
  task :bootstrap do
    VCR.configure do |c|
      c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/spec/integration/cassettes')
      c.hook_into :webmock # or :fakeweb
      c.allow_http_connections_when_no_cassette = true
    end
    
    VCR.use_cassette('pull') do
      Locomotive::Builder.pull("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
    end
    
    Locomotive::Builder.push("site", {"host" => "http://locomotive.engine.dev:3000"}, "email" => "admin@locomotivecms.com", "password" => "locomotive", "force" => true)
  end
end
