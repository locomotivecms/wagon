require 'thor/group'
require 'active_support'
require 'active_support/core_ext'

module Locomotive
  module Wagon
    module Generators
      class Page < Thor::Group

        include Thor::Actions
        include Locomotive::Wagon::CLI::ForceColor

        argument :slug
        argument :target_path # path to the site

        def create_page
          segments      = self.slug.split('/').find_all { |segment| segment != '' }
          max_segments  = segments.size

          while segment = segments.pop do
            _options    = self.page_options(slug: segment, translated: false)
            file_path   = File.join(pages_path, segments, segment)

            # the content type option is never deleted for the first segment (the requested template)
            _options.delete(:content_type) unless segments.size == (max_segments - 1)

            template 'template.liquid.tt', "#{file_path}.liquid", _options

            self.other_locales.each do |locale|
              _options[:translated] = true
              template 'template.liquid.tt', "#{file_path}.#{locale}.liquid", _options
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

        def page_options(base = {})
          base.merge({
            title:        options[:title] || base[:slug].humanize,
            listed:       options[:listed],
            content_type: options[:content_type]
          })
        end

        def other_locales
          return @other_locales if @other_locales

          # Rules:
          # #1 default: [fr, en, es], asked: [en, de], result => [en]
          # #2 default: [fr, en, de], asked: [es], result => []
          # #1 default: [fr, en, es], asked: [fr, en, es], result => [en, es]

          _locales  = options[:locales] || ''
          separator = _locales.include?(',') ? ',' : ' '

          _locales  = _locales.split(separator)
          locales   = options[:default_locales]
          locales.shift

          @other_locales = locales & (_locales || [])
        end

      end

    end
  end
end
