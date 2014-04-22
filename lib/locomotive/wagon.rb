require 'rubygems'
require 'bundler/setup'

require 'common'

require 'locomotive/wagon/initializers'
require 'locomotive/wagon/version'
require 'locomotive/wagon/listen'
require 'better_errors'

begin
  require 'pry'
rescue LoadError
end

module Locomotive
  module Wagon

    # Create a site from a site generator.
    #
    # @param [ String ] name The name of the site (underscored)
    # @param [ String ] path The destination path of the site
    # @param [ Boolean ] skip_bundle Do not run bundle install
    # @param [ Object ] generator The wrapping class of the generator itself
    # @param [ String ] options Options for the generator (ex: --force_haml)
    #
    def self.init(name, path, skip_bundle, generator, options)
      generator.klass.start [name, path, skip_bundle, options]
    end

    # Start the thin server which serves the LocomotiveCMS site from the system.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] options The options for the thin server (host, port)
    #
    def self.serve(path, options)

      if reader = self.require_mounter(path, true)

        require 'locomotive/steam/server'
        app = Locomotive::Steam::Server.new(reader, serve_assets: true)
        use_listen = !options[:disable_listen]

        # TODO: new feature -> pick the right Rack handler (Thin, Puma, ...etc)

        require 'thin'
        server  = Thin::Server.new(options[:host], options[:port], app)
        server.threaded = true

        if options[:force]
          begin
            self.stop(path)
            sleep(2) # make sure we wait enough for the Thin process to stop
          rescue
          end
        end

        if options[:daemonize]
          # very important to get the parent pid in order to differenciate the sub process from the parent one
          parent_pid = Process.pid

          server.log_file = File.join(File.expand_path(path), 'log', 'thin.log')
          server.pid_file = File.join(File.expand_path(path), 'log', 'thin.pid')
          server.daemonize

          use_listen = Process.pid != parent_pid && !options[:disable_listen]
        end
        Locomotive::Wagon::Listen.instance.start(reader) if use_listen

        server.start
      end
    end

    def self.stop(path)
      pid_file = File.join(File.expand_path(path), 'log', 'thin.pid')
      pid = File.read(pid_file).to_i
      Process.kill('TERM', pid)
    end

    # Generate components for the LocomotiveCMS site such as content types, snippets, pages.
    #
    # @param [ Symbol ] name The name of the generator
    # @param [ Array ] *args The arguments for the generator
    #
    def self.generate(name, *args)
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

        reader.mounting_point.site.domains   = connection_info['domains']   if connection_info["domains"]
        reader.mounting_point.site.subdomain = connection_info['subdomain'] if connection_info["subdomain"]
        require 'bundler'

        writer = Locomotive::Mounter::Writer::Api.instance
        self.validate_resources(options[:resources], writer.writers)

        connection_info[:uri] = "#{connection_info.delete(:host)}/locomotive/api"

        _options = { mounting_point: reader.mounting_point, console: true }.merge(options).symbolize_keys
        _options[:only] = _options.delete(:resources)

        writer.run!(_options.merge(connection_info).with_indifferent_access)
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

      connection_info[:uri] = "#{connection_info.delete(:host)}/locomotive/api"

      _options = { console: true }.merge(options).symbolize_keys
      _options[:only] = _options.delete(:resources)

      reader = Locomotive::Mounter::Reader::Api.instance
      self.validate_resources(_options[:only], reader.readers)
      reader.run!(_options.merge(connection_info))

      writer = Locomotive::Mounter::Writer::FileSystem.instance
      writer.run!(_options.merge(mounting_point: reader.mounting_point, target_path: path))
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
      generator.start [name, path, true, connection_info.symbolize_keys]

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
      Locomotive::Common::Logger.setup(File.expand_path(File.join(path, 'log', 'wagon.log')))
      require 'locomotive/mounter'
      Locomotive::Mounter.logger = Locomotive::Common::Logger.instance.logger

      if get_reader
        begin
          reader = Locomotive::Mounter::Reader::FileSystem.instance
          reader.run!(path: path)
          reader
        rescue Exception => e
          raise Locomotive::Common::MounterException.new "Unable to read the local LocomotiveCMS site. Please check the logs.", e
        end
      end
    end

    protected

    def self.validate_resources(resources, writers_or_readers)
      return if resources.nil?
      valid_resources = writers_or_readers.map { |thing| thing.to_s.demodulize.gsub(/Writer$|Reader$/, '').underscore }
      resources.each do |resource|
        raise ArgumentError, "'#{resource}' resource not recognized. Valid resources are #{valid_resources.join(', ')}." unless valid_resources.include?(resource)
      end
    end
  end
end
