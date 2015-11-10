require_relative 'wagon/exceptions'

module Locomotive
  module Wagon

    DEFAULT_PLATFORM_URL = 'http://locomotive.works'.freeze

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
    # @param [ Array ] args [name of the site, destination path of the site, skip bundle flag, force_haml]
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
    def self.serve(path, options)
      require_relative 'wagon/commands/serve_command'
      Locomotive::Wagon::ServeCommand.start(path, options)
    end

    # Stop the thin server.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] force If true, block the current thread for 2s
    #
    def self.stop(path, force = false)
      require_relative 'wagon/commands/serve_command'
      Locomotive::Wagon::ServeCommand.stop(path, force)
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
    def self.sync(env, path, options = {})
      require_relative 'wagon/commands/sync_command'
      Locomotive::Wagon::SyncCommand.sync(env, path, options)
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

    # Destroy a remote site
    #
    # @param [ String ] env The environment we use to deploy the site to
    # @param [ String ] path The path of the site
    # @param [ Hash ] options The options passed to the destroy command
    #
    def self.destroy(env, path, options = {})
      require_relative 'wagon/commands/destroy_command'
      Locomotive::Wagon::DestroyCommand.destroy(env, path, options)
    end

    # Delete a remote resource
    #
    # @param [ String ] env The environment we use to deploy the site to
    # @param [ String ] path The path of the site
    # @param [ String ] resource The resource from which we want to delete an entry
    # @param [ String ] slug The slug of the resource to delete
    def self.delete(env, path, resource, slug)
      require_relative 'wagon/commands/delete_command'
      Locomotive::Wagon::DeleteCommand.delete(env, path, resource, slug)
    end

  end
end
