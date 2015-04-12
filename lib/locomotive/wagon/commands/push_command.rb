require 'locomotive/steam'
require 'netrc'

require_relative 'concerns/api_concern'

module Locomotive::Wagon

  class PushCommand < Struct.new(:env, :path, :options)

    include ApiConcern

    attr_accessor :platform_url, :credentials

    def self.push(env, path, options)
      self.new(env, path, options).push
    end

    def push
      puts connection_information.inspect
      true
    end

    def connection_information
      if information = read_from_yaml_file
        # the deployment env exists and contains all the information we need to move on
        information
      else
        # 1. ask for the platform URL (or LOCOMOTIVE_PLATFORM_URL env variable) [DONE]
        self.platform_url = ask_for_platform_url

        # 2. retrieve email + api_key. If no entry present in the .netrc, raise an error [DONE]
        self.credentials = read_from_netrc(self.platform_url)

        raise 'You need to run wagon authenticate before going further' if self.credentials.nil?

        # 3. get an instance of the Steam services in order to load the information about the site (SiteRepository)
        site = steam_services.current_site

        # 4. ask for a handle if not found (blank: random one)
        site[:handle] ||= ask_for_the_site_handle

        # 5. create the site
        create_remote_site(site)

        'TODO'

        # 6. update the deploy.yml
      end

      # clean the URI (ssl, without scheme?)
      # assign the site to the Steam services and repositories
      # build an instance of the Coal client class
    end

    private

    def create_remote_site(site)
      api_client.sites.create(site.attributes).tap do |_site|
        puts _site.inspect
      end
    end

    def ask_for_platform_url
      default = ENV['LOCOMOTIVE_PLATFORM_URL'] || DEFAULT_PLATFORM_URL

      url = shell.ask "What is the URL of your platform? (default: #{default})"

      url.blank? ? default : url
    end

    def ask_for_the_site_handle
      handle = nil
      while handle.nil?
        handle = shell.ask "What is the handle of your site?"
      end
    end

    def read_from_yaml_file
      # pre-processing: erb code to parse and render?
      parsed_deploy_file = ERB.new(File.open(deploy_file).read).result

      # finally, get the hash from the YAML file
      environments = YAML::load(parsed_deploy_file)
      (environments.is_a?(Hash) ? environments : {})[env.to_s]
    rescue Exception => e
      raise "Unable to read the config/deploy.yml file (#{e.message})"
    end

    def read_from_netrc(platform_url)
      uri = URI(platform_url)
      host_with_port = "#{uri.host}:#{uri.port}"

      if credentials = Netrc.read[host_with_port]
        { url: uri.to_s, email: credentials.email, api_key: credentials.api_key }
      end
    end

    def steam_services
      return @steam_services if @steam_services

      Locomotive::Steam.configure do |config|
        config.mode         = :test
        config.adapter      = { name: :filesystem, path: path }
        config.asset_path   = File.expand_path(File.join(path, 'public'))
      end

      @steam_services = Locomotive::Steam::Services.build_instance.tap do |services|
        repositories = services.repositories
        repositories.current_site = repositories.site.all.first
        services.locale = repositories.current_site.default_locale
      end
    end

    def client
      @client ||= Locomotive::Coal::Client.new(api_url, credentials)
    end

    def deploy_file
      File.join(path, 'config', 'deploy.yml')
    end

    def shell
      options[:shell]
    end

  end

end
