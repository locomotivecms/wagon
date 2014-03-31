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
        # argument :locales

        # options
        # class_option :title,        type: :string,  default: nil, required: false, desc: 'Title?'
        # class_option :haml,         type: :boolean, default: nil, required: false, desc: 'HAML over HTML?'
        # class_option :listed,       type: :boolean, default: nil, required: false, desc: 'Listed in the nav tag?'
        # class_option :content_type, type: :string,  default: nil, required: false, desc: 'Tied to a content type?'

        # attr_accessor :locales

        # def apply_locales?
        #   if self.options[:locales].blank?
        #   self.locales =

        #   self.locales.shift # remove the default locale

        #   unless self.locales.empty?
        #     unless yes?('Do you want to generate templates for each locale ?')
        #       self.locales = []
        #     end
        #   end
        # end

        def create_page
          extension = haml? ? 'liquid.haml' : 'liquid'

          segments = self.slug.split('/')
          while segment = segments.pop do
            _options    = self.page_options(slug: segment, translated: false)
            file_path   = File.join(pages_path, segments, segment)

            template "template.#{extension}.tt", "#{file_path}.#{extension}", _options

            self.other_locales.each do |locale|
              _options[:translated] = true
              template "template.#{extension}.tt", "#{file_path}.#{locale}.#{extension}", _options
            end
          end
        end

        def self.source_root
          File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'generators', 'page')
        end

        protected

        def haml?
          if options[:haml].nil?
            yes?('Do you prefer a HAML template ?')
          else
            options[:haml]
          end
        end

        def pages_path
          File.join(target_path, 'app', 'views', 'pages')
        end

        def page_options(base = {})
          base.merge({
            title:        options[:title] || base[:slug].humanize,
            listed:       options[:listed],
            content_type: options[:content_type]
          })
        end

        def other_locales
          locales = options[:default_locales]
          locales.shift

          # #1 default: [fr, en, es], asked: [en, de], result => [en]
          # #2 default: [fr, en, de], asked: [es], result => []
          # #1 default: [fr, en, es], asked: [fr, en, es], result => [en, es]

          locales & (options[:locales] || [])
        end

        # def locales
        #   self.options[:locales]
        # end

        # def locales=(values)
        #   self.options[:locales] = values
        # end

      end

    end
  end
end