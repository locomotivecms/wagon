module Spec
  module Helpers

    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end

    def remove_logs
      FileUtils.rm_rf(File.expand_path('../../fixtures/default/log', __FILE__))
    end

    def clone_site
      VCR.use_cassette('pull') do
        Locomotive::Wagon.clone('site', '.', { host: 'locomotive.engine.dev:3000', email: 'admin@locomotivecms.com', password: 'locomotive' })
      end
    end

    def run_server
      path = 'spec/fixtures/default'
      Locomotive::Wagon::Logger.setup(path, false)
      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: path)
      Locomotive::Wagon::Server.new(reader, disable_listen: true)
    end

  end
end