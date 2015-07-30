require 'thor'
require 'thor/runner'

module Locomotive
  module Wagon
    module CLI

      module CheckPath

        protected

        # Check if the path given in option ('.' by default) points to a LocomotiveCMS
        # site. It is also possible to pass a path other than the one from the options.
        #
        # @param [ String ] path The optional path of the site instead of options['path']
        #
        # @return [ String ] The fullpath to the LocomotiveCMS site or nil if it is not a valid site.
        #
        def check_path!(path = nil)
          path ||= options['path']

          path = path == '.' ? Dir.pwd : File.expand_path(path)

          site_or_deploy_file = File.exists?(File.join(path, 'config', 'site.yml')) || File.exists?(File.join(path, 'config', 'deploy.yml'))

          (site_or_deploy_file ? path : nil).tap do |_path|
            if _path.nil?
              say 'The path does not point to a LocomotiveCMS site', :red
            end
          end
        end

      end

      module ForceColor

        def force_color_if_asked(options)
          if options[:force_color]
            # thor
            require 'locomotive/wagon/tools/thor'
            self.shell = Thor::Shell::ForceColor.new

            # bypass colorize code
            STDOUT.instance_eval { def isatty; true; end; }
          end
        end

      end

      class Generate < Thor

        include Locomotive::Wagon::CLI::ForceColor
        include Locomotive::Wagon::CLI::CheckPath

        class_option :path, aliases: '-p', type: :string, default: '.', optional: true, desc: 'if your LocomotiveCMS site is not in the current path'

        desc 'content_type SLUG FIELDS', 'Creates a content type with the specified slug and fields.'
        method_option :name, aliases: '-n', type: :string, default: nil, optional: true, desc: 'Name of the content type as it will be displayed in the back-office'
        long_desc <<-LONGDESC
          Create a content type with the specified slug and fields.

          SLUG should be plural, lowercase, and underscored.

          FIELDS format: field_1[:TYPE][:LABEL][:REQUIRED][:LOCALIZED][:TARGET_CONTENT_TYPE_SLUG] field_2[:TYPE][:LABEL][:REQUIRED][:LOCALIZED][:TARGET_CONTENT_TYPE_SLUG] ...

          TYPE values: string, text, integer, float, boolean, email, date, date_time, file, tags, select, belongs_to, has_many, or many_to_many. Default is string.

          To require a field, set REQUIRED to true. The first field is required by default.

          TARGET_CONTENT_TYPE_SLUG is the slug of the content type used in the relationship.

          Examples:

            * wagon generate content_type posts title published_at:date_time:true body:text

            * wagon generate content_type products title price:float photo:file category:belongs_to:Category:true:false:main_categories
        LONGDESC
        def content_type(name, *fields)
          force_color_if_asked(options)

          say('The fields are missing', :red) and return false if fields.empty?

          if path = check_path!
            Locomotive::Wagon.generate :content_type, [name, fields, path], self.options
          end
        end

        desc 'relationship SOURCE TYPE TARGET', 'Relate 2 existing content types.'
        long_desc <<-LONGDESC
          Relate 2 existing content types.

          SOURCE AND TARGET are the slugs of the content types.
          There should be plural, lowercase, and underscored.

          TYPE values: belongs_to, has_many, or many_to_many.

          Examples:

            * wagon generate relationship posts belongs_to categories

            * wagon generate relationship projects many_to_many developers
        LONGDESC
        def relationship(source, type, target)
          force_color_if_asked(options)

          if path = check_path!
            Locomotive::Wagon.generate :relationship, [source, type, target, path], self.options
          end
        end

        desc 'page FULLPATH', 'Create a page. No need to pass an extension to the FULLPATH arg'
        method_option :title,         aliases: '-t', type: 'string',    default: nil, desc: 'Title of the page'
        method_option :haml,          aliases: '-h', type: 'boolean',   default: nil, desc: 'add a HAML extension to the file'
        method_option :listed,        aliases: '-l', type: 'boolean',   default: false, desc: 'tell if the page is listed in the menu'
        method_option :content_type,  aliases: '-c', type: 'string',    default: nil, desc: 'tell if the page is a template for a content type'
        method_option :locales,       aliases: '-lo', type: 'string',   default: nil, desc: 'locales for the various translations'
        long_desc <<-LONGDESC
          Create a page. The generator will ask for the extension (liquid or haml) and also
          if the page is localized or not.

          Examples:

            * wagon generate page contact

            * wagon generate page about_us/me
        LONGDESC
        def page(fullpath)
          force_color_if_asked(options)

          if path = check_path!
            self.options[:default_locales] = self.site_config(path)['locales']
            Locomotive::Wagon.generate :page, [fullpath, path], self.options
          end
        end

        desc 'snippet SLUG', 'Create a snippet'
        long_desc <<-LONGDESC
          Create a snippet. The generator will ask for the extension (liquid or haml) and also
          if the snippet is localized or not.

          Example:

            * wagon generate snippet footer
        LONGDESC
        def snippet(slug)
          force_color_if_asked(options)

          if path = check_path!
            locales = self.site_config(path)['locales']
            Locomotive::Wagon.generate :snippet, [slug, locales, path], self.options
          end
        end

        protected

        # Read the YAML config file of a LocomotiveCMS site.
        # The path should be returned by the check_path! method first.
        #
        # @param [ String ] path The full path to a LocomotiveCMS site.
        #
        # @return [ Hash ] The site
        #
        def site_config(path = nil)
          YAML.load_file(File.join(path, 'config', 'site.yml'))
        end

      end

      class Main < Thor

        include Locomotive::Wagon::CLI::CheckPath
        include Locomotive::Wagon::CLI::ForceColor

        class_option :force_color, type: :boolean, default: false, desc: 'Whether or not to use ANSI color in the output.'

        desc 'version', 'Version of the LocomotiveCMS Wagon'
        def version
          require 'locomotive/wagon/version'
          say Locomotive::Wagon::VERSION
        end

        desc 'auth [EMAIL] [PASSWORD] [PLATFORM_URL]', 'Log into your Locomotive platform'
        def auth(email = nil, password = nil, platform_url = nil)
          say "Locomotive Sign in/up\n\n", :bold

          platform_url ||= ask("Enter the URL of your platform? (default: #{Locomotive::Wagon::DEFAULT_PLATFORM_URL})")
          platform_url = Locomotive::Wagon::DEFAULT_PLATFORM_URL if platform_url.strip == ''
          while email.to_s.strip == ''; email = ask('Enter your e-mail?'); end
          while password.to_s.strip == ''; password = ask('Enter your password?', echo: false); end

          Locomotive::Wagon.authenticate(platform_url, email, password, shell)
        end

        desc 'init NAME [PATH] [GENERATOR_OPTIONS]', 'Create a brand new site'
        method_option :template,    aliases: '-t', type: 'string', default: 'blank', desc: 'instead of building from a blank site, you can also have a pre-fetched site from a template (see the templates command)'
        method_option :lib,         aliases: '-l', type: 'string', desc: 'Path to an external ruby lib or generator'
        method_option :skip_bundle, type: 'boolean', default: false, desc: "Don't run bundle install"
        method_option :verbose,     aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def init(name, path = '.', *generator_options)
          force_color_if_asked(options)
          require 'locomotive/wagon/generators/site'
          require File.expand_path(options[:lib]) if options[:lib]
          generator = Locomotive::Wagon::Generators::Site.get(options[:template])
          if generator.nil?
            say "Unknown site template '#{options[:template]}'", :red
            exit(1)
          else
            begin
              if Locomotive::Wagon.init(generator.klass, [name, path, options[:skip_bundle].to_s, *generator_options], { force_color: options[:force_color] })
                self.print_next_instructions_when_site_created(name, path, options[:skip_bundle])
              end
            rescue GeneratorException => e
              self.print_exception(e, options[:verbose])
              exit(1)
            end
          end
        end

        desc 'clone NAME HOST [PATH]', 'Clone a remote LocomotiveCMS site'
        option :verbose,   aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        option :handle,    aliases: '-h', desc: 'handle of your site'
        option :email,     aliases: '-e', desc: 'email of an administrator account'
        option :password,  aliases: '-p', desc: 'password of an administrator account (use api_key instead)'
        option :api_key,   aliases: '-a', desc: 'api key of an administrator account'
        def clone(name, host, path = '.')
          begin
            if Locomotive::Wagon.clone(name, path, { host: host }.merge(options), shell)
              self.print_next_instructions_when_site_created(name, path, true)
            end
          rescue Exception => e
            self.print_exception(e, options[:verbose])
            exit(1)
          end
        end

        desc 'generate RESOURCE ARGUMENTS [PATH]', 'Generates a content_type, page, or snippet'
        long_desc <<-LONGDESC
          Generates a content_type, page, or snippet

          RESOURCE can be set to content_type, page, or snippet.

          Use wagon generate help [RESOURCE] for usage information and examples.
        LONGDESC
        subcommand 'generate', Generate

        desc 'list_templates', 'List all the templates to create either a site or a content type'
        method_option :lib, aliases: '-l', type: 'string', desc: 'Path to an external ruby lib or generator'
        method_option :json, aliases: '-j', type: :boolean, default: false, desc: 'Output the list in JSON'
        def list_templates
          force_color_if_asked(options)
          require 'locomotive/wagon/generators/site'
          require File.expand_path(options[:lib]) if options[:lib]
          if Locomotive::Wagon::Generators::Site.empty?
            say 'No templates', :red
          elsif !options[:json]
            Locomotive::Wagon::Generators::Site.list.each do |info|
              say info.name, :bold, false
              say " - #{info.description}" unless info.description.blank?
            end
          else
            say Locomotive::Wagon::Generators::Site.list_to_json
          end
        end

        desc 'serve [PATH]', 'Serve a site from the file system'
        method_option :host, aliases: '-h', type: 'string', default: '0.0.0.0', desc: 'The host (address) of the Thin server'
        method_option :port, aliases: '-p', type: 'string', default: '3333', desc: 'The port of the Thin server'
        method_option :daemonize, aliases: '-d', type: 'boolean', default: false, desc: 'Run daemonized Thin server in the background'
        method_option :live_reload_port, aliases: '-l', type: 'string', default: false, desc: 'Include the Livereload javascript in each page'
        method_option :force, aliases: '-f', type: 'boolean', default: false, desc: 'Stop the current daemonized Thin server if found before starting a new one'
        method_option :verbose, aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def serve(path = '.')
          parent_pid = Process.pid
          force_color_if_asked(options)
          if check_path!(path)
            begin
              Locomotive::Wagon.serve(path, options)
            rescue SystemExit => e
              if parent_pid == Process.pid
                say "Your site is served now.", :green
              end
            rescue Exception => e
              self.print_exception(e, options[:verbose])
              exit(1)
            end
          end
        end

        desc 'stop [PATH]', 'Stop serving a site previously launched by the serve command with the -d option'
        def stop(path = '.')
          force_color_if_asked(options)
          if check_path!(path)
            begin
              Locomotive::Wagon.stop(path)
              say "Your site is not served anymore.", :green
            rescue Exception => e
              say e.message, :red
              exit(1)
            end
          end
        end

        desc 'push ENV [PATH]', 'Push a site to a remote LocomotiveCMS Engine'
        method_option :resources, aliases: '-r', type: 'array', default: nil, desc: 'Only push the resource(s) passed in argument'
        method_option :data, aliases: '-d', type: 'boolean', default: false, desc: 'Push the content entries and the editable elements (by default, they are not)'
        method_option :shell, type: 'boolean', default: true, desc: 'Use shell to ask for missing connection information like the site handle (in this case, take a random one)'
        method_option :verbose, aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def push(env, path = '.')
          force_color_if_asked(options)

          if check_path!(path)
            begin
              Locomotive::Wagon.push(env, path, options, options[:shell] ? shell : nil)
            rescue Exception => e
              self.print_exception(e, options[:verbose])
              exit(1)
            end
          end
        end

        desc 'pull ENV [PATH]', 'Pull a site from a remote LocomotiveCMS Engine'
        method_option :resources, aliases: '-r', type: 'array', default: nil, desc: 'Only pull the resource(s) passed in argument'
        method_option :verbose, aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def pull(env, path = '.')
          if check_path!(path)
            begin
              Locomotive::Wagon.pull(env, path, options, options[:shell] ? shell : nil)
            rescue Exception => e
              self.print_exception(e, options[:verbose])
              exit(1)
            end
          end
        end

        desc 'destroy ENV [PATH]', 'Destroy a remote LocomotiveCMS Engine'
        def destroy(env, path = '.')
          if check_path!(path)
            if connection_info = self.retrieve_connection_info(env, path)
              if ask('Are you sure ?', limited_to: %w(yes no)) == 'yes'
                Locomotive::Wagon.destroy(path, connection_info)
              else
                say 'The destroy operation has been cancelled', :red
                exit(1)
              end
            end
          end
        end

        protected

        # Print a nice message when a site has been created.
        #
        # @param [ String ] name The name of the site
        # @param [ String ] path The path of the local site
        # @param [ Boolean ] skip_bundle Do not run bundle install
        #
        def print_next_instructions_when_site_created(name, path, skip_bundle)
          say "\nCongratulations, your site \"#{name}\" has been created successfully !", :green
          say 'Next steps:', :bold

          next_instructions = "\tcd #{path}/#{name}\n\t"
          next_instructions += "bundle install\n\t" unless skip_bundle
          next_instructions += "#{'bundle exec ' unless skip_bundle}wagon serve\n\topen http://0.0.0.0:3333"

          say next_instructions
        end

        # Print the exception.
        #
        # @param [ Object ] exception The raised exception
        # @param [ Boolean ] verbose Print the full backtrace if true
        #
        def print_exception(exception, verbose)
          say exception.message, :red
          if verbose
            say "\t" + exception.backtrace.join("\n\t")
          end
        end

        # # From a site specified by a path, retrieve the information of the connection
        # # for a environment located in the config/deploy.yml file of the site.
        # #
        # # @param [ String ] env The environment (development, staging, production, ...etc)
        # # @param [ String ] path The path of the local site
        # # @param [ Boolean ] use_shell True by default, use it to ask for missing information (subdomain for instance)
        # #
        # # @return [ Hash ] The information of the connection or nil if errors
        # #
        # def retrieve_connection_info(env, path, use_shell = true)
        #   require 'locomotive/wagon/misc/deployment_connection'

        #   begin
        #     service = Locomotive::Wagon::DeploymentConnection.new(path, use_shell ? shell : nil)

        #     service.get_information(env)

        #   rescue Exception => e
        #     self.print_exception(e, options[:verbose])
        #     nil
        #   end
        # end

      end

    end
  end
end
