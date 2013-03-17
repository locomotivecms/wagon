require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Page < Thor::Group

        include Thor::Actions

        argument :slug
        argument :target_path # path to the site
        argument :locales

        attr_accessor :haml

        def ask_for_haml
          self.haml = yes?('Do you prefer a HAML template ?')
        end

        def apply_locales?
          self.locales.shift # remove the default locale

          unless self.locales.empty?
            unless yes?('Do you want to generate templates for each locale ?')
              self.locales = []
            end
          end
        end

        def create_page
          extension = self.haml ? 'liquid.haml' : 'liquid'

          segments = self.slug.split('/')
          while segment = segments.pop do
            options   = { slug: segment, translated: false }
            file_path = File.join(pages_path, segments, segment)

            template "template.#{extension}.tt", "#{file_path}.#{extension}", options

            self.locales.each do |locale|
              options[:translated] = true
              template "template.#{extension}.tt", "#{file_path}.#{locale}.#{extension}", options
            end
          end
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'page')
        end

        protected

        def pages_path
          File.join(target_path, 'app', 'views', 'pages')
        end

      end

    end
  end
end