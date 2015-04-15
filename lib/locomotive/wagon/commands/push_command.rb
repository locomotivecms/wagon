require 'locomotive/steam'

require_relative 'concerns/api_concern'
require_relative 'concerns/netrc_concern'
require_relative 'concerns/deploy_file_concern'
require_relative 'concerns/steam_concern'

require_relative '../decorators/concerns/to_hash_concern'
require_relative '../decorators/site_decorator'
require_relative '../decorators/snippet_decorator'
require_relative '../decorators/translation_decorator'

require_relative 'push_sub_commands/push_base_command'
require_relative 'push_sub_commands/push_snippets_command'
require_relative 'push_sub_commands/push_translations_command'

module Locomotive::Wagon

  class PushCommand < Struct.new(:env, :path, :options)

    include ApiConcern
    include NetrcConcern
    include DeployFileConcern
    include SteamConcern

    attr_accessor :platform_url, :credentials

    def self.push(env, path, options)
      self.new(env, path, options).push
    end

    def push
      api_client = api_site_client(connection_information)

      PushSnippetsCommand.push(api_client, steam_services)
      PushTranslationsCommand.push(api_client, steam_services)

      true
    end

    private

    def connection_information
      if information = read_deploy_settings(self.env, self.path)
        # the deployment env exists and contains all the information we need to move on
        information
      else
        # mandatory to sign in
        load_credentials_from_netrc

        # create the remote site on the platform
        site = create_remote_site

        # update the deploy.yml by adding the new env since we've got all the information
        write_deploy_setings(self.env, self.path, {
          'host'    => api_host,
          'handle'  => site.handle,
          'email'   => credentials[:email],
          'api_key' => credentials[:api_key]
        })
      end
    end

    def create_remote_site
      # get an instance of the Steam services in order to load the information about the site (SiteRepository)
      steam_services.current_site.tap do |site|
        # ask for a handle if not found (blank: random one)
        site[:handle] ||= shell.ask "What is the handle of your site?"

        # create the site
        attributes = SiteDecorator.new(site).to_hash
        _site = api_client.sites.create(attributes)
        site[:handle] = _site.handle
      end
    end

    def load_credentials_from_netrc
      # ask for the platform URL (or LOCOMOTIVE_PLATFORM_URL env variable)
      ask_for_platform_url

      # retrieve email + api_key. If no entry present in the .netrc, raise an error
      self.credentials = read_credentials_from_netrc(self.api_host)

      raise 'You need to run wagon authenticate before going further' if self.credentials.nil?
    end

    def ask_for_platform_url
      default = ENV['LOCOMOTIVE_PLATFORM_URL'] || DEFAULT_PLATFORM_URL

      url = shell.ask "What is the URL of your platform? (default: #{default})"

      self.platform_url = url.blank? ? default : url
    end

    def shell
      options[:shell]
    end

  end

end
