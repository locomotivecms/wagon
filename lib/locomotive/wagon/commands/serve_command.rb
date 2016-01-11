module Locomotive::Wagon

  class ServeCommand < Struct.new(:path, :options)

    attr_reader :use_listen

    def initialize(path, options)
      super(path, options || {})

      @use_listen = !self.options[:disable_listen]
    end

    def self.start(path, options = {})
      new(path, options).start
    end

    def self.stop(path, force = false)
      new(path, nil).stop(force)
    end

    def start
      # make sure the Thin server is not running
      stop(true) if options[:force]

      # Steam is our rendering engine
      require_steam

      daemonize if options[:daemonize]

      # if a page, a content type or any resources of the site is getting modified,
      # then the cache of Steam will be notified.
      listen if use_listen

      # let's start!
      server.start
    end

    def stop(force = false)
      pid = File.read(server_pid_file).to_i
      Process.kill('TERM', pid)

      # make sure we wait enough for the server process to stop
      sleep(2) if force
    end

    private

    def require_steam
      require 'locomotive/steam'
      require 'locomotive/steam/server'
      require 'locomotive/wagon/middlewares/error_page'
      require 'bundler'
      Bundler.require 'misc'

      configure_logger

      Locomotive::Steam.configure do |config|
        config.mode         = :test
        config.adapter      = { name: :filesystem, path: File.expand_path(path) }
        config.asset_path   = File.expand_path(File.join(path, 'public'))

        if (port = options[:live_reload_port]).to_i > 0
          require 'rack-livereload'
          config.middleware.insert_before Rack::Lint, Rack::LiveReload, live_reload_port: port
        end

        config.middleware.insert_before Rack::Lint, Locomotive::Wagon::Middlewares::ErrorPage
      end
    end

    def daemonize
      # very important to get the parent pid in order to differenciate the sub process from the parent one
      parent_pid = Process.pid

      # The Daemons gem closes all file descriptors when it daemonizes the process. So any logfiles that were opened before the Daemons block will be closed inside the forked process.
      # So, close the current logger and set it up again when daemonized.
      Locomotive::Common::Logger.close

      server.log_file = server_log_file
      server.pid_file = server_pid_file
      server.daemonize

      use_listen = use_listen && Process.pid != parent_pid

      # A "new logger" inside the daemon.
      configure_logger if Process.pid != parent_pid
    end

    def listen
      require_relative '../tools/listen'
      require 'locomotive/steam/adapters/filesystem/simple_cache_store'

      cache = Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new

      Locomotive::Wagon::Listen.start(path, cache)
    end

    def server
      @server ||= build_server
    end

    def build_server
      # TODO: new feature -> pick the right Rack handler (Thin, Puma, ...etc)
      require 'thin'

      # Thin in debug mode
      # Thin::Logging.debug = true

      app = Locomotive::Steam.to_app

      Thin::Server.new(options[:host], options[:port], { signals: true }, app).tap do |server|
        server.threaded = true
      end
    end

    def configure_logger
      Locomotive::Common.reset
      Locomotive::Common.configure do |config|
        config.notifier = Locomotive::Common::Logger.setup(log_file)
      end
    end

    def server_pid_file
      File.join(File.expand_path(path), 'log', 'server.pid')
    end

    def server_log_file
      File.join(File.expand_path(path), 'log', 'server.log')
    end

    def log_file
      File.expand_path(File.join(path, 'log', 'wagon.log'))
    end

  end

end
