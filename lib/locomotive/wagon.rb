require_relative 'wagon/exceptions'
require 'oj'

module Locomotive
  module Wagon

    DEFAULT_PLATFORM_URL = 'https://station.locomotive.works'.freeze

    # Authenticate an user to the Hosting platform.
    # If the user does not exist, then create an account for her/him.
    # At the end, store the API key in the ~/.netrc file
    #
    # @param [ String ] email The email of the user
    # @param [ String ] password The password of the user
    # @param [ Object ] shell Used to ask for/prompt information
    #
    def self.authenticate(url, email, password, shell)
      require_relative 'wagon/commands/authenticate_command'
      Locomotive::Wagon::AuthenticateCommand.authenticate(url, email, password, shell)
    end

    # Create a site from a site generator.
    #
    # @param [ Object ] generator The wrapping class of the generator itself
    # @param [ Array ] args [name of the site, destination path of the site]
    # @param [ Hash ] options General options (ex: --force-color)
    #
    def self.init(generator_klass, args, options = {})
      require_relative 'wagon/commands/init_command'
      Locomotive::Wagon::InitCommand.generate(generator_klass, args, options)
    end

    # Start the thin server which serves the LocomotiveCMS site from the system.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] options The options for the thin server (host, port)
    #
    def self.serve(path, options, shell)
      require_relative 'wagon/commands/serve_command'
      Locomotive::Wagon::ServeCommand.start(path, options, shell)
    end

    # Stop the thin server.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] force If true, block the current thread for 2s
    #
    def self.stop(path, force = false, shell)
      require_relative 'wagon/commands/serve_command'
      Locomotive::Wagon::ServeCommand.stop(path, force, shell)
    end

    # Generate components for the LocomotiveCMS site such as content types, snippets, pages.
    #
    # @param [ Symbol ] name The name of the generator
    # @param [ Array ] *args The arguments for the generator
    # @param [ Hash ] options The options for the generator
    #
    def self.generate(name, args, options = {})
      require_relative 'wagon/commands/generate_command'
      Locomotive::Wagon::GenerateCommand.generate(name, args, options)
    end

    # Push a site to a remote LocomotiveCMS engine described
    # by the config/deploy.yml file of the site and for a specific environment.
    #
    # @param [ String ] env The environment we deploy the site to
    # @param [ String ] path The path of the site
    # @param [ Object ] shell The Thor shell used to ask for information if needed
    # @param [ Hash ] options The options passed to the push process
    #
    def self.push(env, path, options = {}, shell)
      require_relative 'wagon/commands/push_command'
      Locomotive::Wagon::PushCommand.push(env, path, options, shell)
    end

    # Pull a site from a remote LocomotiveCMS engine described
    # by the config/deploy.yml file of the site and for a specific environment.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] connection_info The information to get connected to the remote site
    # @param [ Hash ] options The options passed to the pull process
    #
    def self.pull(env, path, options = {}, shell)
      require_relative 'wagon/commands/pull_command'
      Locomotive::Wagon::PullCommand.pull(env, path, options, shell)
    end

    # Synchronize the local content with the one from a remote Locomotive engine.
    # by the config/deploy.yml file of the site and for a specific environment.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] connection_info The information to get connected to the remote site
    # @param [ Hash ] options The options passed to the pull process
    #
    def self.sync(env, path, options = {}, shell)
      require_relative 'wagon/commands/sync_command'
      Locomotive::Wagon::SyncCommand.sync(env, path, options, shell)
    end

    # Clone a site from a remote LocomotiveCMS engine.
    #
    # @param [ String ] name Name of the site (arbitrary)
    # @param [ String ] path The root path where the site will be cloned
    # @param [ Hash ] connection_info The host, email and password needed to access the remote engine
    # @param [ Hash ] options The options for the API reader
    #
    def self.clone(name, path, options, shell)
      require_relative 'wagon/commands/clone_command'
      Locomotive::Wagon::CloneCommand.clone(name, path, options, shell)
    end

    # Delete one or all remote resource(s)
    #
    # @param [ String ] env The environment we use to deploy the site to
    # @param [ String ] path The path of the site
    # @param [ String ] resource The resource from which we want to delete an entry or all entries
    # @param [ String ] slug The slug of the resource to delete
    def self.delete(env, path, resource, slug, shell)
      require_relative 'wagon/commands/delete_command'
      Locomotive::Wagon::DeleteCommand.delete(env, path, resource, slug, shell)
    end

    def self.require_misc_gems
      return if ENV['WAGON_GEMFILE'].nil?

      # at this point, we are sure that in a bundle exec contact
      begin
        require 'bundler'
        ::Bundler.require(:misc)
      rescue Exception => e
        puts "Warning: cant' require the Gemfile misc group, reason: #{e.message}"
        # Bundler is not defined or there is an issue
        # with one of the gems in the misc group
      end
    end

  end
end
