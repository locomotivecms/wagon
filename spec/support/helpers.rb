module Spec
  module Helpers
    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end
    
    def import_site
      VCR.use_cassette('import') do
        Steam.import("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
      end
    end
  end
end