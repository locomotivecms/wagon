module Spec
  module Helpers

    def default_site_path
      File.expand_path('../../fixtures/default', __FILE__)
    end

    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end

    def remove_logs
      FileUtils.rm_rf(File.expand_path('../../fixtures/default/log', __FILE__))
    end

    def restore_deploy_file(path)
      FileUtils.cp(File.join(path, 'config', 'deploy_example.yml'), File.join(path, 'config', 'deploy.yml'))
    end

    # def clone_site
    #   VCR.use_cassette('pull') do
    #     Locomotive::Wagon.clone('site', '.', { host: 'sample.example.com:3000', email: 'admin@locomotivecms.com', password: 'locomotive' })
    #   end
    # end

    def working_copy_of_site(name)
      tmp_path = File.expand_path('../../tmp', __FILE__)
      tmp_path = FileUtils.mkdir_p(tmp_path)
      File.join(tmp_path, name.to_s)
    end

    def make_working_copy_of_site(name)
      source = File.join(File.expand_path('../../fixtures', __FILE__), name.to_s)
      target = working_copy_of_site(name)

      FileUtils.cp_r(source, target)
    end

    def remove_working_copy_of_site(name)
      path = working_copy_of_site(name)
      FileUtils.rm_rf(path)
    end

  end
end
