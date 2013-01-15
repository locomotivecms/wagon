require "bundler/gem_tasks"
require "vcr"
require "locomotive/builder"

namespace :site do
  task :pull do
    VCR.use_cassette('pull') do
      Locomotive::Builder.pull("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
    end
  end
  
  task :push do
    Locomotive::Builder.push("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
  end
end
