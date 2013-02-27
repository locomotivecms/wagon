module Spec
  module Helpers
    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end
    
    def clone_site
      VCR.use_cassette('pull') do
        Locomotive::Wagon.clone("site", {"host" => "locomotive.engine.dev:3000"}, "email" => "admin@locomotivecms.com", "password" => "locomotive")
      end
    end
  end
end