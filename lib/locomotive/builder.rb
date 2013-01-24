require 'locomotive/builder/version'
require 'locomotive/builder/exceptions'

module Locomotive
  module Builder

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
        require 'locomotive/builder/server'

        server = Thin::Server.new(options[:host], options[:port], Locomotive::Builder::Server.new(reader))
        # server.threaded = true # TODO: make it an option ?
        server.start
      end
    end

    # Generate components for the LocomotiveCMS site such as content types, snippets, pages.
    #
    # @param [ Symbol ] name The name of the generator
    # @param [ Array ] *args The arguments for the generator
    #
    def self.generate(name, *args)
      lib = "locomotive/builder/generators/#{name}"
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
        writer = Locomotive::Mounter::Writer::Api.instance

        connection_info['uri'] = "#{connection_info.delete('host')}/locomotive/api"

        _options = { mounting_point: reader.mounting_point, console: true }.merge(options)
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
      puts "loading locomotive mounter"
      self.require_mounter(path)

      connection_info['uri'] = "#{connection_info.delete('host')}/locomotive/api"

      _options = { console: true }.merge(options)
      _options[:only] = _options.delete(:resources)

      puts "============="

      reader = Locomotive::Mounter::Reader::Api.instance
      reader.run!(_options.merge(connection_info))

      puts "------------"

      # writer = Locomotive::Mounter::Writer::FileSystem.instance
      # writer.run!(mounting_point: reader.mounting_point, target_path: path)
    rescue Exception => e
      puts e.backtrace
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
      require 'locomotive/mounter'

      logfile = File.join(path, 'log', 'mounter.log')
      FileUtils.mkdir_p(File.dirname(logfile))

      Locomotive::Mounter.logger = ::Logger.new(logfile).tap do |log|
        log.level = Logger::DEBUG
      end

      begin
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)
        reader
      rescue Exception => e
        Locomotive::Mounter.logger.error e.backtrace
        raise Locomotive::Builder::MounterException.new "Unable to read the local LocomotiveCMS site: #{e.message}\nPlease check the logs file (#{path}/log/mounter.log)"
      end if get_reader
    end


  end
end