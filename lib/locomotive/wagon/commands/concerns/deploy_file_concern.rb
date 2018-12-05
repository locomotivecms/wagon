require 'locomotive/coal'

module Locomotive::Wagon

  module DeployFileConcern

    def write_deploy_settings(env, path, settings)
      File.open(deploy_file(path), 'a+') do |f|
        f.write({ env => settings }.to_yaml.sub(/^---/, ''))
      end

      settings
    end

    def read_deploy_settings(env, path)
      # pre-processing: erb code to parse and render?
      parsed_deploy_file = ERB.new(File.open(deploy_file(path)).read).result

      # finally, get the hash from the YAML file
      environments = YAML::load(parsed_deploy_file)
      (environments.is_a?(Hash) ? environments : {})[env.to_s]
    rescue Exception => e
      raise "Unable to read the config/deploy.yml file (#{e.message})"
    end

    def deploy_file(path)
      File.join(path, 'config', 'deploy.yml')
    end

  end

end
