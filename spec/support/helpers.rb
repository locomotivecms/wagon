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
        Locomotive::Wagon.clone('site', '.', { host: 'sample.example.com:3000', email: 'admin@locomotivecms.com', password: 'locomotive' })
      end
    end

    def run_server
      path = 'spec/fixtures/default'
      Locomotive::Common::Logger.setup(path, false)
      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: path)
      Locomotive::Steam::Server.new(reader, disable_listen: true)
    end

    def open_in_browser
      path = File.join(File.dirname(__FILE__), '..', 'tmp', "wagon-#{Time.new.strftime("%Y%m%d%H%M%S")}#{rand(10**10)}.html")
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path,'w') { |f| f.write last_response.body }
      Launchy.open(path)
    end

  end
end