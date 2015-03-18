module Locomotive
  module Wagon
    module Liquid
      module Tags
        class PathTo < ::Liquid::Tag

          include PathHelper

          Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @handle = $1
              @_options = {}
              markup.scan(::Liquid::TagAttributes) do |key, value|
                @_options[key] = value
              end
            else
              raise SyntaxError.new("Syntax Error in 'path_to' - Valid syntax: path_to <page|page_handle|content_entry>(, locale: [fr|de|...], with: <page_handle>")
            end

            super
          end

          def render(context)
            render_path(context)
          end

        end

        ::Liquid::Template.register_tag('path_to', PathTo)
      end
    end
  end
end