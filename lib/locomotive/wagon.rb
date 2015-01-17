require 'locomotive/wagon/version'
require 'locomotive/wagon/logger'
require 'locomotive/wagon/exceptions'

module Locomotive
  module Wagon

    # Authenticate an user to the Hosting platform.
    # If the user does not exist, then create an account for her/him.
    # At the end, store the API key in the ~/.netrc file
    #
    # @param [ String ] email The email of the user
    # @param [ String ] password The password of the user
    # @param [ Object ] shell Used to ask for/prompt information
    #
    def self.authenticate(email, password, shell)
      require 'locomotive/wagon/misc/hosting_api'
      require 'netrc'

      api_key = nil
      api     = Locomotive::HostingAPI.new(email: email, password: password)

      if api.authenticated?
        # existing account
        api_key = api.api_key
        shell.say "You have been successfully authenticated.", :green
      else
        # new account?
        shell.say "No account found for #{email} or invalid credentials", :yellow

        if shell.yes?('Do you want to create a new account? [Y/N]')
          name = shell.ask 'What is your name?'

          account = api.create_account(name: name, email: email, password: password)

          if account.success?
            shell.say "Your account has been successfully created.", :green
            api_key = account['api_key']
          else
            shell.say "We were unable to create your account, reason(s): #{account.error_messages.join(', ')}", :red
          end
        end
      end

      if api_key
        # record the credentials
        netrc = Netrc.read
        netrc[api.domain_with_port] = email, api_key
        netrc.save
      else
        shell.say "We were unable to authenticate you on our platform.", :red
      end
    end

    # Create a site from a site generator.
    #
    # @param [ Object ] generator The wrapping class of the generator itself
    # @param [ Array ] args [name of the site, destination path of the site, skip bundle flag, force_haml]
    # @param [ Hash ] options General options (ex: --force-color)
    #
    def self.init(generator_klass, args, options = {})
      args, opts = Thor::Options.split(args)

      generator = generator_klass.new(args, opts, {})
      generator.force_color_if_asked(options)
      generator.invoke_all
    end

    # Start the thin server which serves the LocomotiveCMS site from the system.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] options The options for the thin server (host, port)
    #
    def self.serve(path, options)
      if reader = self.require_mounter(path, true)
        use_listen = !options[:disable_listen]

        if options[:force]
          begin
            self.stop(path)
            sleep(2) # make sure we wait enough for the server process to stop
          rescue
          end
        end

        # TODO: new feature -> pick the right Rack handler (Thin, Puma, ...etc)
        server = self.thin_server(reader, options.slice(:host, :port, :disable_listen, :live_reload_port))

        if options[:daemonize]
          # very important to get the parent pid in order to differenciate the sub process from the parent one
          parent_pid = Process.pid

          # The Daemons gem closes all file descriptors when it daemonizes the process. So any logfiles that were opened before the Daemons block will be closed inside the forked process.
          # So, close the current logger and set it up again when daemonized.
          Locomotive::Wagon::Logger.close

          server.log_file = File.join(File.expand_path(path), 'log', 'server.log')
          server.pid_file = File.join(File.expand_path(path), 'log', 'server.pid')
          server.daemonize

          use_listen = Process.pid != parent_pid && !options[:disable_listen]

          if Process.pid != parent_pid
            # A "new logger" inside the daemon.
            Locomotive::Wagon::Logger.setup(path, false)
            Locomotive::Mounter.logger = Locomotive::Wagon::Logger.instance.logger
          end
        end

        # listen_thread = Thread.new do
        Locomotive::Wagon::Listen.instance.start(reader) if use_listen

        server.start
        # end

        # server_thread = Thread.new { server.start }

        # hit Control + C to stop
        # Signal.trap('INT')  { EventMachine.stop }
        # Signal.trap('TERM') { EventMachine.stop }

        # listen_thread.join
        # server_thread.join
      end
    end

    def self.stop(path)
      pid_file = File.join(File.expand_path(path), 'log', 'server.pid')
      pid = File.read(pid_file).to_i
      Process.kill('TERM', pid)
    end

    # Generate components for the LocomotiveCMS site such as content types, snippets, pages.
    #
    # @param [ Symbol ] name The name of the generator
    # @param [ Array ] *args The arguments for the generator
    # @param [ Hash ] options The options for the generator
    #
    def self.generate(name, args, options = {})
      Bundler.require 'misc'

      lib = "locomotive/wagon/generators/#{name}"
      require lib

      generator = lib.camelize.constantize.new(args, options, { behavior: :skip })
      generator.destination_root = args.last
      generator.force_color_if_asked(options)
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

        reader.mounting_point.site.domains   = connection_info['domains']   if connection_info['domains']
        reader.mounting_point.site.subdomain = connection_info['subdomain'] if connection_info['subdomain']

        writer    = Locomotive::Mounter::Writer::Api.instance
        resources = self.validate_resources(options[:resources], writer.writers)

        connection_info[:uri] = "#{connection_info.delete(:host)}/locomotive/api"

        _options = { mounting_point: reader.mounting_point, only: resources, console: true }.merge(options).symbolize_keys

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
      self.require_mounter(path, false, options[:disable_misc])

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
    # @param [ Boolean ] require_misc Tell if it requires the gems inside the misc bundler group
    #
    # @param [ Object ] An instance of the reader is the get_reader parameter has been set.
    #
    def self.require_mounter(path, get_reader = false, require_misc = true)
      Locomotive::Wagon::Logger.setup(path, false)

      require 'locomotive/mounter'

      Locomotive::Mounter.logger = Locomotive::Wagon::Logger.instance.logger

      if require_misc
        require 'bundler'
        Bundler.require 'misc'
      end

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

    protected

    def self.thin_server(reader, options)
      require 'locomotive/wagon/server'
      app = Locomotive::Wagon::Server.new(reader, options)

      # TODO: new feature -> pick the right Rack handler (Thin, Puma, ...etc)
      require 'thin'
      Thin::Server.new(options[:host], options[:port], { signals: true }, app).tap do |server|
        server.threaded = true
      end
    end

    def self.validate_resources(resources, writers_or_readers)
      return if resources.nil?

      # FIXME: for an unknown reason, when called from Cocoa, the resources are a string
      resources = resources.map { |resource| resource.split(' ') }.flatten

      valid_resources = writers_or_readers.map { |thing| thing.to_s.demodulize.gsub(/Writer$|Reader$/, '').underscore }

      resources.each do |resource|
        raise ArgumentError, "'#{resource}' resource not recognized. Valid resources are #{valid_resources.join(', ')}." unless valid_resources.include?(resource)
      end

      resources
    end

  end
end
