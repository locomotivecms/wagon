require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Section < Thor::Group

        ICON_LIST = ['header',
                     'default',
                     'slide',
                     'text',
                     'image_text',
                     'list',
                     'footer']

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :slug
        argument :global
        argument :icon
        argument :target_path # path to the site

        def is_global?
          if self.global.blank?
            self.global = yes?('Is this section aimed to be used as global?')
          end
        end

        def wich_icon?
          if self.icon.blank?
            question = 'Which icon should be displayed in the backoffice?'
            self.icon = ask(question, limited_to: ICON_LIST)
          end
        end

        def create_section
          _slug = slug.clone.downcase.gsub(/[-]/, '_')

          options   = { name: _slug.humanize, type: _slug, global: self.global, icon: self.icon }
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
