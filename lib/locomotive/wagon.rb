require 'locomotive/wagon/version'
require 'locomotive/wagon/logger'
require 'locomotive/wagon/exceptions'

module Locomotive
  module Wagon

    # Create a site from a site generator.
    #
    # @param [ String ] name The name of the site (underscored)
    # @param [ String ] path The destination path of the site
    # @param [ Object ] generator The wrapping class of the generator itself
    #
    def self.init(name, path, generator)
      generator.klass.start [name, path]
    end

    # Start the thin server which serves the LocomotiveCMS site from the system.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] options The options for the thin server (host, port)
    #
    def self.serve(path, options)
      if reader = self.require_mounter(path, true)
        Bundler.require 'misc'

        require 'thin'
        require 'locomotive/wagon/server'

        server = Thin::Server.new(options[:host], options[:port], Locomotive::Wagon::Server.new(reader))
        server.threaded = true # TODO: make it an option ?
        server.start
      end
    end

    # Generate components for the LocomotiveCMS site such as content types, snippets, pages.
    #
    # @param [ Symbol ] name The name of the generator
    # @param [ Array ] *args The arguments for the generator
    #
    def self.generate(name, *args)
      Bundler.require 'misc'

      lib = "locomotive/wagon/generators/#{name}"
      require lib

      generator = lib.camelize.constantize.new(args, {}, {})
      generator.invoke_all
    end

    # Push a site to a remote LocomotiveCMS engine described
    # by the config/deploy.yml file of the site and for a specific environment.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] connection_info The information to get connected to the remote site
    # @param [ Hash ] options The options passed to the push process
    #
    def self.push(path, connection_info, options = {})
      if reader = self.require_mounter(path, true)
        Bundler.require 'misc'

        writer = Locomotive::Mounter::Writer::Api.instance

        connection_info['uri'] = "#{connection_info.delete('host')}/locomotive/api"

        _options = { mounting_point: reader.mounting_point, console: true }.merge(options).symbolize_keys
        _options[:only] = _options.delete(:resources)

        writer.run!(_options.merge(connection_info))
      end
    end

    # Pull a site from a remote LocomotiveCMS engine described
    # by the config/deploy.yml file of the site and for a specific environment.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] connection_info The information to get connected to the remote site
    # @param [ Hash ] options The options passed to the pull process
    #
    def self.pull(path, connection_info, options = {})
      self.require_mounter(path)

      Bundler.require 'misc' unless options[:disable_misc]

      connection_info['uri'] = "#{connection_info.delete('host')}/locomotive/api"

      _options = { console: true }.merge(options)
      _options[:only] = _options.delete(:resources)

      reader = Locomotive::Mounter::Reader::Api.instance
      reader.run!(_options.merge(connection_info))

      writer = Locomotive::Mounter::Writer::FileSystem.instance
      writer.run!(mounting_point: reader.mounting_point, target_path: path)
    end

    # Clone a site from a remote LocomotiveCMS engine.
    #
    # @param [ String ] name Name of the site (arbitrary)
    # @param [ String ] path The root path where the site will be cloned
    # @param [ Hash ] connection_info The host, email and password needed to access the remote engine
    # @param [ Hash ] options The options for the API reader
    #
    def self.clone(name, path, connection_info, options = {})
      target_path = File.expand_path(File.join(path, name))

      if File.exists?(target_path)
        puts "Path already exists. If it's an existing site, you might want to pull instead of clone."
        return false
      end

      # generate an almost blank site
      require 'locomotive/wagon/generators/site'
      generator = Locomotive::Wagon::Generators::Site::Cloned
      generator.start [name, path, connection_info]

      # pull the remote site
      self.pull(target_path, options.merge(connection_info).with_indifferent_access, { disable_misc: true })
    end

    # Destroy a remote site
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] connection_info The information to get connected to the remote site
    # @param [ Hash ] options The options passed to the push process
    #
    def self.destroy(path, connection_info, options = {})
      self.require_mounter(path)

      connection_info['uri'] = "#{connection_info.delete('host')}/locomotive/api"

      Locomotive::Mounter::EngineApi.set_token connection_info.symbolize_keys
      Locomotive::Mounter::EngineApi.delete('/current_site.json')
    end

    # Load the Locomotive::Mounter lib and set it up (logger, ...etc).
    # If the second parameter is set to true, then the method builds
    # an instance of the reader from the path passed in first parameter.
    #
    # @param [ String ] path The path to the local site
    # @param [ Boolean ] get_reader Tell if it builds an instance of the reader.
    #
    # @param [ Object ] An instance of the reader is the get_reader parameter has been set.
    #
    def self.require_mounter(path, get_reader = false)
      Locomotive::Wagon::Logger.setup(path, false)

      require 'locomotive/mounter'

      Locomotive::Mounter.logger = Locomotive::Wagon::Logger.instance.logger

      if get_reader
        begin
          reader = Locomotive::Mounter::Reader::FileSystem.instance
          reader.run!(path: path)
          reader
        rescue Exception => e
          raise Locomotive::Wagon::MounterException.new "Unable to read the local LocomotiveCMS site. Please check the logs.", e
        end
      end
    end

  end
end