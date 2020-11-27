require 'thor'
require 'thor/runner'

module Locomotive
  module Wagon
    module CLI

      module CheckPath

        protected

        # Check if the path given in option ('.' by default) points to a Locomotive
        # site. It is also possible to pass a path other than the one from the options.
        #
        # @param [ String ] path The optional path of the site instead of options['path']
        #
        # @return [ String ] The fullpath to the Locomotive site or nil if it is not a valid site.
        #
        def check_path!(path = nil)
          path ||= options['path']

          path = path == '.' ? Dir.pwd : File.expand_path(path)

          site_or_deploy_file = File.exists?(File.join(path, 'config', 'site.yml')) || File.exists?(File.join(path, 'config', 'deploy.yml'))

          (site_or_deploy_file ? path : nil).tap do |_path|
            if _path.nil?
              say 'The path does not point to a Locomotive site', :red
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

        class_option :path, aliases: '-p', type: :string, default: '.', optional: true, desc: 'if your Locomotive site is not in the current path'

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
        method_option :listed,        aliases: '-l', type: 'boolean',   default: false, desc: 'tell if the page is listed in the menu'
        method_option :content_type,  aliases: '-c', type: 'string',    default: nil, desc: 'tell if the page is a template for a content type'
        method_option :locales,       aliases: '-lo', type: 'string',   default: nil, desc: 'locales for the various translations'
        long_desc <<-LONGDESC
          Create a page. The generator will ask if the page is localized or not.

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
          Create a snippet. The generator will ask if the snippet is localized or not.

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

        desc 'section SLUG SETTINGS', 'Create a section'
        long_desc <<-LONGDESC
          Create a section. The generator will ask if the section is global or not.

          Example:

            * wagon generate section hero
            * wagon generate section carousel -i slide title:text block:slide:title:text block:slide:image:image_picker
        LONGDESC
        method_option :global,    aliases: '-g', type: 'boolean',   default: nil, desc: 'tell if the section is global'
        method_option :icon,      aliases: '-i', type: 'string',    default: nil, desc: 'icon displayed the back-office'
        def section(slug, *settings)
          force_color_if_asked(options)

          if path = check_path!
            Locomotive::Wagon.generate :section, [slug, settings, path], self.options
          end
        end

        desc 'public_form', 'Generate a public form like a contact form'
        def public_form
          force_color_if_asked(options)

          if path = check_path!
            Locomotive::Wagon.generate :public_form, [path], self.options
          end
        end

        desc 'site_metafields', 'Generate the missing file to describe the site metafields'
        def site_metafields
          force_color_if_asked(options)

          if path = check_path!
            Locomotive::Wagon.generate :site_metafields, [path], self.options
          end
        end

        desc 'webpack', 'Add Webpack to your v3.x Wagon site'
        def webpack
          force_color_if_asked(options)

          if path = check_path!
            Locomotive::Wagon.generate :webpack, [path], self.options
          end
        end

        protected

        # Read the YAML config file of a Locomotive site.
        # The path should be returned by the check_path! method first.
        #
        # @param [ String ] path The full path to a Locomotive site.
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

        desc 'version', 'Version of the Locomotive Wagon'
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
        method_option :lib,         aliases: '-l', type: 'string', desc: 'Path to an external ruby lib or generator'
        method_option :verbose,     aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def init(name, path = '.', *generator_options)
          force_color_if_asked(options)
          require 'locomotive/wagon/generators/site'
          require File.expand_path(options[:lib]) if options[:lib]
          generator = Locomotive::Wagon::Generators::Site.get(:blank)
          if generator.nil?
            say "Unknown site template '#{options[:template]}'", :red
            exit(1)
          else
            begin
              if Locomotive::Wagon.init(generator.klass, [name, path, *generator_options], { force_color: options[:force_color] })
                self.print_next_instructions_when_site_created(name, path)
              end
            rescue GeneratorException => e
              self.print_exception(e, options[:verbose])
              exit(1)
            end
          end
        end

        desc 'backup NAME HOST [PATH]', 'Backup a remote Locomotive site'
        option :verbose,   aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        option :handle,    aliases: '-h', desc: 'handle of your site'
        option :email,     aliases: '-e', desc: 'email of an administrator account'
        option :password,  aliases: '-p', desc: 'password of an administrator account (use api_key instead)'
        option :api_key,   aliases: '-a', desc: 'api key of an administrator account'
        def backup(name, host, path = '.')
          begin
            if Locomotive::Wagon.clone(name, path, { host: host }.merge(options), shell)
              self.print_next_instructions_when_site_created(name, path, false)
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
        option :lib, aliases: '-l', type: 'string', desc: 'Path to an external ruby lib or generator'
        option :json, aliases: '-j', type: :boolean, default: false, desc: 'Output the list in JSON'
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
        option :host, aliases: '-h', type: 'string', default: '0.0.0.0', desc: 'The host (address) of the Thin server'
        option :port, aliases: '-p', type: 'string', default: '3333', desc: 'The port of the Thin server'
        option :env, aliases: '-e', type: 'string', default: 'local', desc: 'The env used to the data of the pages and content entries'
        option :daemonize, aliases: '-d', type: 'boolean', default: false, desc: 'Run daemonized Thin server in the background'
        option :force_polling, aliases: '-o', type: 'boolean', default: false, desc: 'Force polling of files for reload'
        option :force, aliases: '-f', type: 'boolean', default: false, desc: 'Stop the current daemonized Thin server if found before starting a new one'
        option :verbose, aliases: '-v', type: 'boolean', default: false, desc: 'Display the full error stack trace if an error occurs'
        option :debug, type: 'boolean', default: false, desc: 'Display some debugging information (rack middleware stack)'
        def serve(path = '.')
          force_color_if_asked(options)
          if check_path!(path)
            begin
              Locomotive::Wagon.serve(path, options, shell)
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
              Locomotive::Wagon.stop(path, false, shell)
            rescue Exception => e
              say e.message, :red
              exit(1)
            end
          end
        end

        desc 'deploy ENV [PATH]', 'Deploy a site to a remote Locomotive Engine'
        option :resources, aliases: '-r', type: 'array', default: nil, desc: 'Only push the resource(s) passed in argument'
        option :filter, aliases: '-f', type: 'array', default: nil, desc: 'Push specific resource entries'
        option :data, aliases: '-d', type: 'boolean', default: false, desc: 'Push the content entries and the editable elements (by default, they are not)'
        option :env, aliases: '-e', type: 'string', default: 'local', desc: 'The env used to the data of the pages and content entries'
        option :shell, type: 'boolean', default: true, desc: 'Use shell to ask for missing connection information like the site handle (in this case, take a random one)'
        option :verbose, aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def deploy(env, path = '.')
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

        desc 'sync ENV [PATH]', 'Synchronize the local content with the one from a remote Locomotive site.'
        option :resources, aliases: '-r', type: 'array', default: nil, desc: 'Only pull the resource(s) passed (pages, content_entries, translations) in argument'
        option :verbose, aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def sync(env, path = '.')
          if check_path!(path)
            begin
              Locomotive::Wagon.sync(env, path, options, shell)
            rescue Exception => e
              self.print_exception(e, options[:verbose])
              exit(1)
            end
          end
        end

        desc 'pull ENV [PATH]', '[DEPRECATED, use sync instead] Pull a site from a remote Locomotive Engine.'
        option :resources, aliases: '-r', type: 'array', default: nil, desc: 'Only pull the resource(s) passed in argument'
        option :verbose, aliases: '-v', type: 'boolean', default: false, desc: 'display the full error stack trace if an error occurs'
        def pull(env, path = '.')
          if check_path!(path)
            begin
              Locomotive::Wagon.pull(env, path, options, shell)
            rescue Exception => e
              self.print_exception(e, options[:verbose])
              exit(1)
            end
          end
        end

        desc 'delete ENV RESOURCE [SLUG] [PATH]', 'Delete a resource from a remote Locomotive Engine.'
        long_desc <<-LONGDESC
          Deletes a site, page, content_type, snippet, section, theme_asset or translation from the remote Locomotive Engine.

          It can also delete all the items of a resource if you pass: content_types, snippets, theme_assets or translations as the RESOURCE.

          If you need to delete the whole site for the current ENV, just pass site as the RESOURCE.

          RESOURCE can be set to site, page, content_type(s), snippet(s), theme_asset(s) or translation(s).
          SLUG is the slug of the specific resource to delete
        LONGDESC
        def delete(env, resource, slug = nil, path = '.')
          if ask('Are you sure?', limited_to: %w(yes no)) == 'yes'
            Locomotive::Wagon.delete(env, path, resource, slug, shell)
          else
            say 'The delete operation has been cancelled', :red
            exit(1)
          end
        end

        # aliases
        map push: :deploy, clone: :backup

        protected

        # Print a nice message when a site has been created.
        #
        # @param [ String ] name The name of the site
        # @param [ String ] path The path of the local site
        # @param [ Boolean ] assets True (default) if we want to display the instructions about Webpack
        #
        def print_next_instructions_when_site_created(name, path, assets = true)
          say "\nCongratulations, your site \"#{name}\" has been created successfully !", :green
          say "\nNext steps:\n", :bold
          say "\n# Run the local web server", :on_blue
          say "\n\tcd #{path}/#{name}"
          say "\twagon serve"
          if assets
            say "\n# Compile assets (in a another terminal, use tmux for instance)", :on_blue
            say "\n\tyarn"
            say "\tyarn start"
          end
          say "\n# Preview your site!", :on_blue
          say "\n\topen http://0.0.0.0:3333\n\n", :bold
        end

        # Print the exception.
        #
        # @param [ Object ] exception The raised exception
        # @param [ Boolean ] verbose Print the full backtrace if true
        #
        def print_exception(exception, verbose)
          if verbose
            say "\n# Error description:", :bold
            say exception.message, :red
            say "\n# Backtrace:", :bold
            say "\n\t" + exception.backtrace.join("\n\t")
          else
            say "\n\nError(s) found. Please use the -v option to display the full exception", :red
          end
        end

      end

    end
  end
end
