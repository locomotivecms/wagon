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
          _slug   = slug.clone.downcase.gsub(/[-]/, '_')
          options = { name: _slug.humanize, type: _slug, global: self.global, icon: self.icon }

          # create the liquid file
          file_path = File.join(sections_path, _slug)
          template "template.liquid.tt", "#{file_path}.liquid", options

          # create the javascript file
          if File.exists?(sections_js_path)
            js_class_name = options[:type].classify
            file_path     = File.join(sections_js_path, options[:type])

            template "%type%.js.tt", "#{file_path}.js", options

            append_to_file File.join(sections_js_path, 'index.js'), <<-JS
export { default as #{js_class_name} } from './#{options[:type]}';
            JS

            insert_into_file 'app/assets/javascripts/app.js', after: "// Register sections here. DO NOT REMOVE OR UPDATE THIS LINE\n" do
              "  sectionsManager.registerSection('#{options[:type]}', Sections.#{js_class_name});\n"
            end
          end
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'section')
        end

        protected

        def sections_path
          File.join(target_path, 'app', 'views', 'sections')
        end

        def sections_js_path
          File.join(target_path, 'app', 'assets', 'javascripts', 'sections')
        end

      end

    end
  end
end
