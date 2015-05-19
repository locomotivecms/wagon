require_relative 'wagon/exceptions'

module Locomotive
  module Wagon

    DEFAULT_PLATFORM_URL = 'http://www.lvh.me:3000'.freeze

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
    def self.pull(path, connection_info, options = {})
      raise 'TODO'
      # self.require_mounter(path, false, options[:disable_misc])

      # connection_info[:uri] = "#{connection_info.delete(:host)}/locomotive/api"

      # _options = { console: true }.merge(options).symbolize_keys
      # _options[:only] = _options.delete(:resources)

      # reader = Locomotive::Mounter::Reader::Api.instance
      # self.validate_resources(_options[:only], reader.readers)
      # reader.run!(_options.merge(connection_info))

      # writer = Locomotive::Mounter::Writer::FileSystem.instance
      # writer.run!(_options.merge(mounting_point: reader.mounting_point, target_path: path))
    end

    # Clone a site from a remote LocomotiveCMS engine.
    #
    # @param [ String ] name Name of the site (arbitrary)
    # @param [ String ] path The root path where the site will be cloned
    # @param [ Hash ] connection_info The host, email and password needed to access the remote engine
    # @param [ Hash ] options The options for the API reader
    #
    def self.clone(name, path, connection_info, options = {})
      raise 'TODO'
      # target_path = File.expand_path(File.join(path, name))

      # if File.exists?(target_path)
      #   puts "Path already exists. If it's an existing site, you might want to pull instead of clone."
      #   return false
      # end

      # # generate an almost blank site
      # require 'locomotive/wagon/generators/site'
      # generator = Locomotive::Wagon::Generators::Site::Cloned
      # generator.start [name, path, true, connection_info.symbolize_keys]

      # # pull the remote site
      # self.pull(target_path, options.merge(connection_info).with_indifferent_access, { disable_misc: true })
    end

    # Destroy a remote site
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] connection_info The information to get connected to the remote site
    # @param [ Hash ] options The options passed to the push process
    #
    def self.destroy(path, connection_info, options = {})
      raise 'TODO'
      # self.require_mounter(path)

      # connection_info['uri'] = "#{connection_info.delete('host')}/locomotive/api"

      # Locomotive::Mounter::EngineApi.set_token connection_info.symbolize_keys
      # Locomotive::Mounter::EngineApi.delete('/current_site.json')
    end

    # protected

    # def self.validate_resources(resources, writers_or_readers)
    #   return if resources.nil?

    #   # FIXME: for an unknown reason, when called from Cocoa, the resources are a string
    #   resources = resources.map { |resource| resource.split(' ') }.flatten

    #   valid_resources = writers_or_readers.map { |thing| thing.to_s.demodulize.gsub(/Writer$|Reader$/, '').underscore }

    #   resources.each do |resource|
    #     raise ArgumentError, "'#{resource}' resource not recognized. Valid resources are #{valid_resources.join(', ')}." unless valid_resources.include?(resource)
    #   end

    #   resources
    # end

  end
end
