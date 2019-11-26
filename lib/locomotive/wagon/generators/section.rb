require 'thor/group'
require 'faker'
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
        argument :settings
        argument :target_path # path to the site

        def is_global?
          if (@global = self.options[:global]).nil?
            @global = yes?('Is this section aimed to be used as global (same content for all the pages)?')
          end
        end

        def which_icon?
          if (@icon = self.options[:icon]).nil?
            question = 'Which icon should be displayed in the editor UI?'
            @icon = ask(question, limited_to: ICON_LIST)
          end
        end

        def build_options
          @_slug   = slug.clone.downcase.gsub(/[-]/, '_')
          @options = {
            name:       @_slug.humanize,
            type:       @_slug,
            global:     @global,
            icon:       @icon,
            settings:   extract_section_settings,
            blocks:     extra_blocks,
            all_icons:  ICON_LIST
          }
        end

        def create_section
          # create the liquid file
          file_path = File.join(sections_path, @_slug)
          template "template.liquid.tt", "#{file_path}.liquid", @options
        end

        def create_javascript_file
          if File.exists?(sections_js_path)
            js_class_name = @options[:type].classify
            file_path     = File.join(sections_js_path, @options[:type])

            template "%type%.js.tt", "#{file_path}.js", @options

            append_to_file File.join(sections_js_path, 'index.js'), <<-JS
export { default as #{js_class_name} } from './#{@options[:type]}';
            JS

            insert_into_file 'app/assets/javascripts/app.js', after: "// Register sections here. DO NOT REMOVE OR UPDATE THIS LINE\n" do
              "  sectionsManager.registerSection('#{@options[:type]}', Sections.#{js_class_name});\n"
            end
          end
        end

        def create_stylesheet_file
          if File.exists?(sections_css_path)
            css_class_name  = "#{@options[:type].dasherize}-section"
            file_path       = File.join(sections_css_path, @options[:type])

            template "%type%.scss.tt", "#{file_path}.scss", @options

            insert_into_file 'app/assets/stylesheets/app.scss', after: "// Register sections here. DO NOT REMOVE OR UPDATE THIS LINE\n" do
              "@import 'sections/#{@options[:type]}';\n"
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

        def sections_css_path
          File.join(target_path, 'app', 'assets', 'stylesheets', 'sections')
        end

        def extract_section_settings
          # build section settings only
          settings.map do |raw_setting|
            next if raw_setting.starts_with?('block:') # block setting
            id, type = raw_setting.split(':')
            SectionSetting.new(id, type)
          end.compact.presence || default_section_settings
        end

        def extra_blocks
          # build block settings
          _settings = settings.map do |raw_setting|
            next unless raw_setting.starts_with?('block:') # block setting
            _, block_type, id, type = raw_setting.split(':')
            BlockSetting.new(block_type, id, type)
          end.compact.presence || []

          if settings.blank?
            _settings = default_block_settings
          end

          # group them by block types
          _settings.group_by { |setting| setting.block_type }
        end

        def default_section_settings
          [
            SectionSetting.new('title', 'text', 'My awesome title'),
            SectionSetting.new('image', 'image_picker', 'An image')
          ]
        end

        def default_block_settings
          [
            BlockSetting.new('list_item', 'title', 'text', 'Item title'),
            BlockSetting.new('list_item', 'image', 'image_picker', 'Item image')
          ]
        end

      end

      class SectionSetting

        attr_reader :id, :type, :label

        def initialize(id, type, label = nil)
          @id, @type, @label = id, type || 'text', label || id.humanize
        end

        def default
          case type
          when 'text' then "\"#{Faker::Lorem.sentence}\""
          when 'image_picker' then "\"/samples/images/default.svg\""
          when 'checkbox' then true
          when 'radio', 'select' then 'option_1'
          when 'url' then "\"#\""
          else
            nil
          end
        end

        def has_value?
          !%w(hint content_type).include?(type)
        end

      end

      class BlockSetting < SectionSetting

        attr_reader :block_type

        def initialize(block_type, id, type, label = nil)
          super(id, type, label)
          @block_type = block_type
        end

      end

    end
  end
end
