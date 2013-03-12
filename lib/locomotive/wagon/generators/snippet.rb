require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Snippet < Thor::Group

        include Thor::Actions

        argument :slug
        argument :target_path # path to the site

        attr_accessor :haml, :locales

        def ask_for_haml_and_locales
          self.locales = []
          self.haml    = yes?('Do you prefer a HAML template ?')

          if yes?('Is your snippet localized ?')
            self.locales = ask('What are the locales other than the default one (comma separated) ?').split(',').map(&:strip)
          end
        end

        def create_snippet
          extension = self.haml ? 'liquid.haml' : 'liquid'

          options   = { slug: slug, translated: false }
          file_path = File.join(pages_path, slug)

          template "template.#{extension}.tt", "#{file_path}.#{extension}", options

          self.locales.each do |locale|
            options[:translated] = true
            template "template.#{extension}.tt", "#{file_path}.#{locale}.#{extension}", options
          end
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'snippet')
        end

        protected

        def pages_path
          File.join(target_path, 'app', 'views', 'snippets')
        end

      end

    end
  end
end