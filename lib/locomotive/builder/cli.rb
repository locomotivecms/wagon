require 'thor'
require 'thor/runner'

module Locomotive
  module Builder
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

        include Locomotive::Builder::CLI::CheckPath

        class_option :path, aliases: '-p', type: :string, default: '.', optional: true, desc: 'if your LocomotiveCMS site is not in the current path'

        desc 'content_type NAME FIELDS', 'Create a content type with NAME as the slug and FIELDS as the list of fields.'
        long_desc <<-LONGDESC
          Create a content type with NAME as the slug and FIELDS as the list of fields.
          The fields follows that schema:

          field_1[:type][:required] field_2[:type][:required]

          Examples:

            * builder generate content_type songs name:string duration:string

            * builder generate content_type posts title body:text:true published_at:date
        LONGDESC
        def content_type(name, *fields)
          say('The fields are missing', :red) and return false if fields.empty?

          if check_path!
            Locomotive::Builder.generate :content_type, name, self.options['path'], fields
          end
        end

        desc 'page FULLPATH', 'Create a page. No need to pass an extension to the FULLPATH arg'
        long_desc <<-LONGDESC
          Create a page. The generator will ask for the extension (liquid or haml) and also
          if the page is localized or not.

          Examples:

            * builder generate page contact

            * builder generate page about_us/me
        LONGDESC
        def page(fullpath)
          if check_path!
            Locomotive::Builder.generate :page, fullpath, self.options['path']
          end
        end

        desc 'snippet SLUG', 'Create a snippet'
        long_desc <<-LONGDESC
          Create a snippet. The generator will ask for the extension (liquid or haml) and also
          if the snippet is localized or not.

          Example:

            * builder generate snippet footer
        LONGDESC
        def snippet(slug)
          if check_path!
            Locomotive::Builder.generate :snippet, slug, self.options['path']
          end
        end

      end

      class Main < Thor

        include Locomotive::Builder::CLI::CheckPath

        desc 'init NAME [PATH]', 'Create a brand new LocomotiveCMS site'
        method_option :template, aliases: '-t', type: 'string', default: 'blank', desc: 'instead of building from a blank site, you can have a pre-fetched site with form a template (see the templates command)'
        def init(name, path = '.')
          require 'locomotive/builder/generators/site'
          generator = Locomotive::Builder::Generators::Site.get(options[:template])
          if generator.nil?
            say "Unknown site template '#{options[:template]}'", :red
          else
            Locomotive::Builder.init(name, path, generator)
          end
        end

        desc 'generate TYPE ...ARGS', 'Generate resources (content_types, page, snippets) for a LocomotiveCMS site'
        subcommand 'generate', Generate

        desc 'list_templates', 'List all the templates to create either a site or a content type'
        def list_templates
          require 'locomotive/builder/generators/site'
          if Locomotive::Builder::Generators::Site.empty?
            say 'No templates', :red
          else
            Locomotive::Builder::Generators::Site.list.each do |info|
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
            Locomotive::Builder.serve(path, options)
          end
        end

        desc 'push ENV [PATH]', 'Push a site to a remote LocomotiveCMS engine'
        method_option :resources, aliases: '-r', type: 'array', default: [], desc: 'Only push the resource(s) passed in argument'
        method_option :force, aliases: '-f', type: 'boolean', default: false, desc: 'Force the push of a resource'
        def push(env, path = '.')
          if check_path!(path)
            begin
              path_to_deploy_file = File.join(path, 'config', 'deploy.yml')
              connection_info = YAML::load(File.open(path_to_deploy_file).read)[env.to_s]

              raise "No #{env.to_s} environment found in the config/deploy.yml file" if connection_info.nil?

              Locomotive::Builder.push(path, connection_info, options)
            rescue Exception => e
              say "Unable to read the information about the remote LocomotiveCMS site (#{e.message})", :red
            end
          end
        end

        # desc "push [PATH] SITE_URL EMAIL PASSWORD", "Push a site created by the builder to a remote LocomotiveCMS engine"
        # def push(path, site_url, email, password)
        #   Locomotive::Builder.push(path, site_url, email, password)
        # end

        # desc "pull NAME SITE_URL EMAIL PASSWORD", "Pull an existing LocomotiveCMS site powered by the engine"
        # def pull(name, site_url, email, password)
        #   say("ERROR: \"#{name}\" directory already exists", :red) and return if File.exists?(name)
        #   Locomotive::Builder.pull(name, site_url, email, password)
        # end

      end

    end
  end
end