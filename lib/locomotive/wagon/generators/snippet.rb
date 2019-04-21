require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Snippet < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :slug
        argument :locales
        argument :target_path # path to the site

        def apply_locales?
          self.locales.shift # remove the default locale

          unless self.locales.empty?
            unless yes?('Do you want to generate files for each locale?')
              self.locales = []
            end
          end
        end

        def create_snippet
          _slug = slug.clone.downcase.gsub(/[-]/, '_')

          options   = { slug: _slug, translated: false }
          file_path = File.join(snippets_path, _slug)

          template "template.liquid.tt", "#{file_path}.liquid", options

          self.locales.each do |locale|
            options[:translated] = true
            template "template.liquid.tt", "#{file_path}.#{locale}.liquid", options
          end
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'snippet')
        end

        protected

        def snippets_path
          File.join(target_path, 'app', 'views', 'snippets')
        end

      end

    end
  end
end
