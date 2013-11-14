module Locomotive
  module Wagon
    module Liquid
      module Tags

        class UrlTo < ::Liquid::Tag

          include UrlHelper

          Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @handle = $1
              @_options = {}
              markup.scan(::Liquid::TagAttributes) do |key, value|
                @_options[key] = value
              end
            else
              raise SyntaxError.new("Syntax Error in 'url_to' - Valid syntax: url_to <page|page_handle|content_entry>(, locale: [fr|de|...], with: <page_handle>")
            end

            super
          end

          def render(context)
            render_url(context)
          end

        end

        ::Liquid::Template.register_tag('url_to', UrlTo)
      end
    end
  end
end