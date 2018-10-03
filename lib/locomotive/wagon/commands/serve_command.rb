module Locomotive::Wagon

  SiteFinder = Struct.new(:repository, :request) { def find; repository.first; end; }

  class ServeCommand < Struct.new(:path, :options, :shell)

    def initialize(path, options, shell)
      super(path, options || {}, shell)
      @parent_id = nil
    end

    def self.start(path, options = {}, shell)
      new(path, options, shell).start
    end

    def self.stop(path, force = false, shell)
      new(path, nil, shell).stop(force)
    end

    def start
      # make sure the Thin server is not running
      stop(true) if options[:force]

      # Steam is our rendering engine
      require_steam

      if options[:daemonize]
        daemonize
      else
        setup_signals

        show_start_message

        show_rack_middleware_stack if options[:debug]
      end

      # if a page, a content type or any resources of the site is getting modified,
      # then the cache of Steam will be cleared.
      listen if @parent_pid.nil? || Process.pid != @parent_pid

      # let's start!
      server.start

    rescue SystemExit => e
      show_start_message if @parent_pid == Process.pid
    end

    def stop(force = false)
      unless File.exists?(server_pid_file)
        shell.say "No Wagon server is running.", :red
        return
      end

      pid = File.read(server_pid_file).to_i
      Process.kill('TERM', pid)

      shell.say "\nShutting down Wagon server"

      # make sure we wait enough for the server process to stop
      sleep(2) if force
    end

    private

    def require_steam
      require 'haml'
      require 'locomotive/steam'
      require 'locomotive/steam/server'
      require 'locomotive/wagon/middlewares/error_page'
      require 'bundler'

      configure_logger

      subscribe_to_notifications

      Locomotive::Steam.configure do |config|
        config.mode           = :test
        config.adapter        = { name: :filesystem, path: File.expand_path(path), env: options[:env] }
        config.asset_path     = File.expand_path(File.join(path, 'public'))
        config.minify_assets  = false

        if (port = options[:live_reload_port]).to_i > 0
          require 'rack-livereload'
          config.middleware.insert_before Rack::Lint, Rack::LiveReload, live_reload_port: port
        end

        config.middleware.insert_before Rack::Lint, Locomotive::Wagon::Middlewares::ErrorPage

        config.services_hook = -> (services) {
          if services.request
            services.defer(:site_finder) do
              SiteFinder.new(services.repositories.site, services.request)
            end
          end
        }
      end

      Bundler.require 'misc'
    end

    def daemonize
      # very important to get the parent pid in order to differenciate the sub process from the parent one
      @parent_pid = Process.pid

      # The Daemons gem closes all file descriptors when it daemonizes the process. So any logfiles that were opened before the Daemons block will be closed inside the forked process.
      # So, close the current logger and set it up again when daemonized.
      Locomotive::Common::Logger.close

      server.log_file = server_log_file
      server.pid_file = server_pid_file

      server.daemonize

      # A "new logger" inside the daemon.
      configure_logger if Process.pid != @parent_pid
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

      # Do not display the default Thin server startup message
      Thin::Logging.logger = Logger.new(server_log_file)

      # Thin in debug mode only if the THIN_DEBUG_ON has been set in the shell
      Thin::Logging.debug = ENV['THIN_DEBUG_ON']

      app = Locomotive::Steam.to_app

      Thin::Server.new(options[:host], options[:port], { signals: false }, app).tap do |server|
        server.threaded = true
        server.log_file = server_log_file
      end
    end

    def configure_logger
      # make sure the logs folder exist and get rid of that ugly error message if it doesn't
      FileUtils.mkdir_p(File.join(path, 'log'))

      Locomotive::Common.reset
      Locomotive::Common.configure do |config|
        logger = options[:daemonize] ? log_file : nil
        config.notifier = Locomotive::Common::Logger.setup(logger)
      end
    end

    def subscribe_to_notifications
      # Page not found
      ActiveSupport::Notifications.subscribe('steam.render.page_not_found') do |name, start, finish, id, payload|
        fullpath, locale, default_locale = payload[:path], payload[:locale], payload[:default_locale]

        filepath = File.join(File.expand_path(path), 'app', 'views', 'pages', fullpath + (locale != default_locale ? ".#{locale}" : '') + '.liquid')

        message = if File.exists?(filepath)
          "[Warning]".red + ' by default and unless you overide the slug in the YAML header of your page, Wagon will replace underscores by dashes in your page slug. Try this instead: ' + fullpath.dasherize.light_white
        else
          "[Tip]".light_white + " add a new page in your Wagon site at this location: " + filepath.light_white
        end

        Locomotive::Common::Logger.info (' ' * 2) + message
      end
    end

    def setup_signals
      %w(INT TERM).each do |signal|
        trap(signal) do
          show_stop_message

          EM.add_timer(1) do
            server.stop
          end
        end
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

    def show_rack_middleware_stack
      shell.say "[Rendering stack]".colorize(color: :light_white, background: :blue)

      Locomotive::Steam.configuration.middleware.list.each do |middleware|
        shell.say "\t" + middleware.first.first.inspect
      end

      shell.say "\n"
    end

    def show_start_message
      shell.say "Your site is served now.\nBrowse http://#{options[:host]}:#{options[:port]}\n\n", :green
    end

    def show_stop_message
      shell.say "\nShutting down Wagon server"
    end

  end

end
