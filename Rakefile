require "bundler/gem_tasks"
require "vcr"
require "locomotive/builder"

namespace :site do
  task :pull do
    VCR.configure do |c|
      c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/spec/integration/cassettes')
      c.hook_into :webmock # or :fakeweb
    end
    
    VCR.use_cassette('pull') do
      Locomotive::Builder.pull("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
    end
  end
  
  task :push do
    Locomotive::Builder.push("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
  end
end
