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
      api_client = api_site_client(connection_information_from_env_and_path)

      api_client.current_site.destroy
    end

  end

end
