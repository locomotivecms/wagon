require_relative  'concerns/api_concern'
require_relative  'concerns/deploy_file_concern'

module Locomotive::Wagon

  class DestroyCommand < Struct.new(:env, :path, :options)

    include ApiConcern
    include DeployFileConcern

    def self.destroy(env, path, options)
      self.new(env, path, options).destroy
    end

    def destroy
      api_client = api_site_client(connection_information)

      api_client.current_site.destroy
    end

    private

    def connection_information
      read_deploy_settings(self.env, self.path)
    end

  end

end
