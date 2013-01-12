require 'thor'

module Locomotive
  module Builder
    class CLI < Thor

      desc 'init NAME [PATH]', 'Create a brand new LocomotiveCMS site'
      method_option :template, aliases: '-t', type: 'string', default: 'blank', desc: 'instead of building from a blank site, you can have a pre-fetched site with form a template (see the templates command)'
      def init(name, path = '.')
        require 'locomotive/builder/generators'
        generator = Locomotive::Builder::Generators.get(options[:template])
        if generator.nil?
          say "Unknown site template '#{options[:template]}'", :red
        else
          Locomotive::Builder.init(name, path, generator)
        end
      end

      desc 'serve [PATH]', 'Serve a LocomotiveCMS site from the file system'
      method_option :host, aliases: '-h', type: 'string', default: '0.0.0.0', desc: "The host (address) of the Thin server"
      method_option :port, aliases: '-p', type: 'string', default: '3333', desc: "The port of the Thin server"
      def serve(path = '.')
        Locomotive::Builder.serve(path, options)
      end

      desc "pull NAME SITE_URL EMAIL PASSWORD", "Pull an existing LocomotiveCMS site powered by the engine"
      def pull(name, site_url, email, password)
        say("ERROR: \"#{name}\" directory already exists", :red) and return if File.exists?(name)
        Locomotive::Builder.pull(name, site_url, email, password)
      end

      desc "push PATH SITE_URL EMAIL PASSWORD", "Push a site created by the builder to a remote LocomotiveCMS engine"
      def push(path, site_url, email, password)
        Locomotive::Builder.push(path, site_url, email, password)
      end

      desc "list_templates", "List all the templates to create either a site or a content type"
      def list_templates
        require 'locomotive/builder/generators'
        if Locomotive::Builder::Generators.empty?(:site)
          say "No templates", :red
        else
          Locomotive::Builder::Generators.list(:site).each do |info|
            say info.name, :bold, false
            say " - #{info.description}" unless info.description.blank?
          end
        end
      end

    end
  end
end