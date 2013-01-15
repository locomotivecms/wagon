module Spec
  module Helpers
    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end
    
    def pull_site
      VCR.use_cassette('pull') do
        Locomotive::Builder.pull("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
      end
    end
  end
end