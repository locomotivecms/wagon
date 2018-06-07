require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Section < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :slug
        argument :static
        argument :target_path # path to the site

        def is_static?
          if self.static.blank?
            self.static = yes?('Is this section aimed to be used as static?')
          end
        end

        def create_section
          _slug = slug.clone.downcase.gsub(/[-]/, '_')

          options   = { name: _slug.humanize, type: _slug, static: self.static }
          file_path = File.join(sections_path, _slug)

          template "template.liquid.tt", "#{file_path}.liquid", options
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'section')
        end

        protected

        def sections_path
          File.join(target_path, 'app', 'views', 'sections')
        end

      end

    end
  end
end
