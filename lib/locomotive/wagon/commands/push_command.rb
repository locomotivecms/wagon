require 'locomotive/steam'

require_relative 'loggers/push_logger'

require_relative_all 'concerns'
require_relative_all '../decorators/concerns'
require_relative_all '../decorators'
require_relative_all 'push_sub_commands'

module Locomotive::Wagon

  class PushCommand < Struct.new(:env, :path, :options)

    RESOURCES = %w(content_types content_entries snippets theme_assets translations).freeze

    RESOURCES_WITH_CONTENT = %w(content_entries translations).freeze

    include ApiConcern
    include NetrcConcern
    include DeployFileConcern
    include SteamConcern
    include InstrumentationConcern

    attr_accessor :platform_url, :credentials

    def self.push(env, path, options)
      self.new(env, path, options).push
    end

    def push
      PushLogger.new if options[:verbose]

      api_client = api_site_client(connection_information)

      content_assets_pusher = Locomotive::Wagon::PushContentAssetsCommand.new(api_client, steam_services)

      each_resource do |klass|
        klass.push(api_client, steam_services, content_assets_pusher)
      end
    end

    private

    def each_resource
      RESOURCES.each do |name|
        next if !options[:resources].blank? && !options[:resources].include?(name)

        next if RESOURCES_WITH_CONTENT.include?(name) && !options[:data]

        klass = "Locomotive::Wagon::Push#{name.camelcase}Command".constantize

        yield klass
      end
    end

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

        instrument :site_created, site: site
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
