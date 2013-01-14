require 'thor'
require 'thor/runner'

module Locomotive
  module Builder
    module CLI

      class Generate < Thor

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

          if path = check_path!
            Locomotive::Builder.generate :content_type, name, self.options['path'], fields
          else
            say 'The path does not point to a LocomotiveCMS site', :red
          end
        end

        desc 'page PATH', 'Create a page whose NAME is its fullpath'
        def page(path)
          puts "TODO [page] #{path}"
        end

        desc 'snippet NAME', 'Create a snippet'
        def snippet(name)
          puts "TODO [snippet] #{name}"
        end

        protected

        # Check if the path given in option ('.' by default) points to a LocomotiveCMS
        # site.
        #
        # @return [ String ] The fullpath to the LocomotiveCMS site or nil if it is not a valid site.
        #
        def check_path!
          path = options['path'] == '.' ? Dir.pwd : File.expand_path(options['path'])

          File.exists?(File.join(path, 'config', 'site.yml')) ? path : nil
        end

      end

      class Main < Thor

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
          Locomotive::Builder.serve(path, options)
        end

        # desc "pull NAME SITE_URL EMAIL PASSWORD", "Pull an existing LocomotiveCMS site powered by the engine"
        # def pull(name, site_url, email, password)
        #   say("ERROR: \"#{name}\" directory already exists", :red) and return if File.exists?(name)
        #   Locomotive::Builder.pull(name, site_url, email, password)
        # end

        # desc "push PATH SITE_URL EMAIL PASSWORD", "Push a site created by the builder to a remote LocomotiveCMS engine"
        # def push(path, site_url, email, password)
        #   Locomotive::Builder.push(path, site_url, email, password)
        # end
      end

    end
  end
end