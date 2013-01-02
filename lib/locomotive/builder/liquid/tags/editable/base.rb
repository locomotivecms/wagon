module Locomotive
  module Builder
    module Liquid
      module Tags
        module Editable
          class Base < ::Liquid::Block

            Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/

            def initialize(tag_name, markup, tokens, context)
              if markup =~ Syntax
                @slug = $1.gsub(/[\"\']/, '')
                @options = {}
                markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
              else
                raise ::Liquid::SyntaxError.new("Syntax Error in 'editable_xxx' - Valid syntax: editable_xxx <slug>(, <options>)")
              end

              super
            end

            def render(context)
              current_page = context.registers[:page]

              element = current_page.find_editable_element(context['block'].try(:name), @slug)

              if element.present?
                render_element(context, element)
              else
                super
              end
            end

            protected

            def render_element(context, element)
              element.content
            end

          end

        end
      end
    end
  end
end