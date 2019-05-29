require 'locomotive/steam'

require_relative 'loggers/push_logger'

require_relative_all  'concerns'
require_relative_all  '../decorators/concerns'
require_relative_all  '../decorators'
require_relative      '../tools/glob'

require_relative      'push_sub_commands/push_base_command'
require_relative_all  'push_sub_commands'

module Locomotive::Wagon

  class PushCommand < Struct.new(:env, :path, :options, :shell)

    RESOURCES = %w(site content_types content_entries pages snippets sections theme_assets translations).freeze

    RESOURCES_WITH_CONTENT = %w(content_entries translations).freeze

    include ApiConcern
    include NetrcConcern
    include DeployFileConcern
    include SteamConcern
    include InstrumentationConcern
    include SpinnerConcern

    attr_accessor :platform_url, :credentials

    def self.push(env, path, options, shell)
      self.new(env, path, options, shell).push
    end

    def push
      require_misc_gems

      api_client = build_api_site_client(connection_information)

      return if api_client.nil?

      # Ask for a confirmation (Warning) if we deploy with the -d option
      # since it alters content on the remote engine
      if options[:data] && self.env == 'production'
        return unless ask_for_performing("Warning! You're about to deploy data which will alter the content of your site.")
      end

      if options[:verbose]
        PushLogger.new
        _push(api_client)
      else
        show_wait_spinner('Deploying...') { _push(api_client) }
      end
    end

    private

    def _push(api_client)
      validate!

      content_assets_pusher = Locomotive::Wagon::PushContentAssetsCommand.new(api_client, steam_services)

      each_resource do |klass|
        klass.push(api_client, steam_services, content_assets_pusher, remote_site) do |pusher|
          pusher.with_data if options[:data]
          pusher.only(options[:filter]) unless options[:filter].blank?
        end
      end

      print_result_message
    end

    # To push all the other resources, the big requirement is to
    # have the same locales between the local site and the remote one.
    def validate!
      if local_site.default_locale != remote_site.default_locale && remote_site.edited?
        raise "Your Wagon site locale (#{local_site.default_locale}) is not the same as the one in the back-office (#{remote_site.default_locale})."
      end

      if local_site.locales != remote_site.locales
        instrument :warning, message: "Your Wagon site locales (#{local_site.locales.join(', ')}) are not the same as the ones in the back-office (#{remote_site.locales.join(', ')})."
      end
    end

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
        # warn the user that we're going to create a new site. Ask her/him if we continue
        return unless ask_for_performing('You are about to deploy a new site')

        # mandatory to sign in
        load_credentials_from_netrc

        return if self.credentials.nil?

        # create the remote site on the platform
        site = create_remote_site

        # update the deploy.yml by adding the new env since we've got all the information
        write_deploy_settings(self.env, self.path, {
          'host'    => api_host,
          'handle'  => site.handle,
          'email'   => credentials[:email],
          'api_key' => credentials[:api_key]
        }.tap { |options| options['ssl'] = true if api_host.ends_with?(':443') })
      end
    end

    def create_remote_site
      # get an instance of the Steam services in order to load the information about the site (SiteRepository)
      steam_services.current_site.tap do |site|
        # ask for a handle if not found (blank: random one)
        if (handle = shell.try(:ask, "What is the handle of your site? (default: a random one)")).present?
          site[:handle] = handle
        end

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

      if self.credentials.nil?
        shell.say "Sorry, we were unable to find the credentials for this platform.\nPlease first login using the \"bundle exec wagon auth\"", :yellow
      end
    end

    def ask_for_platform_url
      default = ENV['LOCOMOTIVE_PLATFORM_URL'] || DEFAULT_PLATFORM_URL

      url = shell.try(:ask, "What is the URL of your platform? (default: #{default})")

      self.platform_url = url.blank? ? default : url
    end

    def local_site
      return @local_site if @local_site
      @local_site = SiteDecorator.new(steam_services.repositories.site.first)
    end

    def remote_site
      return @remote_site if @remote_site

      attribute = nil

      begin
        attributes = @api_site_client.current_site.get.attributes
      rescue Locomotive::Coal::UnknownResourceError
        shell.say 'Sorry, we were unable to find your site on the remote platform. Check the information in your config/deploy.yml file.', :red
        raise 'Unable to find your site on the remote platform'
      end

      _site         = Locomotive::Steam::Site.new(attributes)
      @remote_site  = SiteDecorator.new(_site)
    end

    def require_misc_gems
      require 'haml'
      require 'bundler'
      Bundler.require 'misc'
    end

    def ask_for_performing(message)
      shell.say(message, :yellow)

      unless shell.yes?("Are you sure you want to perform this action? (answer yes or no)")
        shell.say("Deployment abandonned!", :yellow)
        return false
      end

      true
    end

    def print_result_message
      shell.say "\n\nYour site has been deployed.", :green

      if remote_site.respond_to?(:preview_url)
        shell.say "\nTo preview your site, visit: #{remote_site.preview_url.light_white}"
      end

      if remote_site.respond_to?(:sign_in_url)
        shell.say "To edit the content of your site, visit: #{remote_site.sign_in_url.light_white}"
      end

      true
    end

  end

end
