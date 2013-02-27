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
        # @param [ String ] path The optional path instead of options['path']
        #
        # @return [ String ] The fullpath to the LocomotiveCMS site or nil if it is not a valid site.
        #
        def check_path!(path = nil)
          path ||= options['path']

          path = path == '.' ? Dir.pwd : File.expand_path(path)

          (File.exists?(File.join(path, 'config', 'site.yml')) ? path : nil).tap do |_path|
            if _path.nil?
              say 'The path does not point to a LocomotiveCMS site', :red
            end
          end
        end

      end

      class Generate < Thor

        include Locomotive::Wagon::CLI::CheckPath

        class_option :path, aliases: '-p', type: :string, default: '.', optional: true, desc: 'if your LocomotiveCMS site is not in the current path'

        desc 'content_type NAME FIELDS', 'Create a content type with NAME as the slug and FIELDS as the list of fields.'
        long_desc <<-LONGDESC
          Create a content type with NAME as the slug and FIELDS as the list of fields.
          The fields follows that schema:

          field_1[:type][:required] field_2[:type][:required]

          Examples:

            * wagon generate content_type songs name:string duration:string

            * wagon generate content_type posts title body:text:true published_at:date
        LONGDESC
        def content_type(name, *fields)
          say('The fields are missing', :red) and return false if fields.empty?

          if check_path!
            Locomotive::Wagon.generate :content_type, name, self.options['path'], fields
          end
        end

        desc 'page FULLPATH', 'Create a page. No need to pass an extension to the FULLPATH arg'
        long_desc <<-LONGDESC
          Create a page. The generator will ask for the extension (liquid or haml) and also
          if the page is localized or not.

          Examples:

            * wagon generate page contact

            * wagon generate page about_us/me
        LONGDESC
        def page(fullpath)
          if check_path!
            Locomotive::Wagon.generate :page, fullpath, self.options['path']
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
          if check_path!
            Locomotive::Wagon.generate :snippet, slug, self.options['path']
          end
        end

      end

      class Main < Thor

        include Locomotive::Wagon::CLI::CheckPath

        desc 'version', 'Version of the LocomotiveCMS wagon'
        def version
          require 'locomotive/wagon/version'
          say Locomotive::Wagon::VERSION
        end

        desc 'init NAME [PATH]', 'Create a brand new LocomotiveCMS site'
        method_option :template, aliases: '-t', type: 'string', default: 'blank', desc: 'instead of building from a blank site, you can have a pre-fetched site with form a template (see the templates command)'
        def init(name, path = '.')
          require 'locomotive/wagon/generators/site'
          generator = Locomotive::Wagon::Generators::Site.get(options[:template])
          if generator.nil?
            say "Unknown site template '#{options[:template]}'", :red
          else
            begin
              Locomotive::Wagon.init(name, path, generator)
            rescue GeneratorException => e
              say e.message, :red
            end
          end
        end

        desc 'generate TYPE ...ARGS', 'Generate resources (content_types, page, snippets) for a LocomotiveCMS site'
        subcommand 'generate', Generate

        desc 'list_templates', 'List all the templates to create either a site or a content type'
        def list_templates
          require 'locomotive/wagon/generators/site'
          if Locomotive::Wagon::Generators::Site.empty?
            say 'No templates', :red
          else
            Locomotive::Wagon::Generators::Site.list.each do |info|
              say info.name, :bold, false
              say " - #{info.description}" unless info.description.blank?
            end
          end
        end

        desc 'serve [PATH]', 'Serve a LocomotiveCMS site from the file system'
        method_option :host, aliases: '-h', type: 'string', default: '0.0.0.0', desc: 'The host (address) of the Thin server'
        method_option :port, aliases: '-p', type: 'string', default: '3333', desc: 'The port of the Thin server'
        def serve(path = '.')
          if check_path!(path)
            begin
              Locomotive::Wagon.serve(path, options)
            rescue Exception => e
              say e.message, :red
            end
          end
        end

        desc 'push ENV [PATH]', 'Push a site to a remote LocomotiveCMS engine'
        method_option :resources, aliases: '-r', type: 'array', default: nil, desc: 'Only push the resource(s) passed in argument'
        method_option :force, aliases: '-f', type: 'boolean', default: false, desc: 'Force the push of a resource'
        method_option :data, aliases: '-d', type: 'boolean', default: false, desc: 'Push the content entries and the editable elements (by default, they are not)'
        def push(env, path = '.')
          if check_path!(path)
            if connection_info = self.retrieve_connection_info(env, path)
              begin
                Locomotive::Wagon.push(path, connection_info, options)
              rescue Exception => e
                say e.message, :red
              end
            end
          end
        end

        desc 'pull ENV [PATH]', 'Pull a site from a remote LocomotiveCMS engine'
        method_option :resources, aliases: '-r', type: 'array', default: nil, desc: 'Only pull the resource(s) passed in argument'
        # method_option :force, aliases: '-f', type: 'boolean', default: false, desc: 'Force the push of a resource'
        # method_option :data, aliases: '-d', type: 'boolean', default: false, desc: 'Push the content entries and the editable elements (by default, they are not)'
        def pull(env, path = '.')
          if check_path!(path)
            if connection_info = self.retrieve_connection_info(env, path)
              begin
                Locomotive::Wagon.pull(path, connection_info, options)
              rescue Exception => e
                say e.message, :red
              end
            end
          end
        end

        desc 'destroy ENV [PATH]', 'Destroy a remote LocomotiveCMS engine'
        def destroy(env, path = '.')
          if check_path!(path)
            if connection_info = self.retrieve_connection_info(env, path)
              if ask('Are you sure ?', limited_to: %w(yes no)) == 'yes'
                Locomotive::Wagon.destroy(path, connection_info)
              else
                say 'The destroy operation has been cancelled', :red
              end
            end
          end
        end

        # desc "pull NAME SITE_URL EMAIL PASSWORD", "Pull an existing LocomotiveCMS site powered by the engine"
        # def pull(name, site_url, email, password)
        #   say("ERROR: \"#{name}\" directory already exists", :red) and return if File.exists?(name)
        #   Locomotive::Wagon.pull(name, site_url, email, password)
        # end

        protected

        # From a site specified by a path, retrieve the information of the connection
        # for a environment located in the config/deploy.yml file of the site.
        #
        # @param [ String ] env The environment (development, staging, production, ...etc)
        # @param [ String ] path The path of the local site
        #
        # @return [ Hash ] The information of the connection or nil if errors
        #
        def retrieve_connection_info(env, path)
          connection_info = nil
          begin
            path_to_deploy_file = File.join(path, 'config', 'deploy.yml')
            connection_info = YAML::load(File.open(path_to_deploy_file).read)[env.to_s]

            if connection_info.nil?
              raise "No #{env.to_s} environment found in the config/deploy.yml file"
            end
          rescue Exception => e
            say "Unable to read the information about the remote LocomotiveCMS site (#{e.message})", :red
          end
          connection_info
        end

      end

    end
  end
end