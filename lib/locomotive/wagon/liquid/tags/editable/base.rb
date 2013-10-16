module Locomotive
  module Wagon
    module Liquid
      module Tags
        module Editable
          class Base < ::Liquid::Block

            Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/

            def initialize(tag_name, markup, tokens, options)
              if markup =~ Syntax
                @slug = $1.gsub(/[\"\']/, '')
                @_options = {}
                markup.scan(::Liquid::TagAttributes) { |key, value| @_options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
              else
                raise ::Liquid::SyntaxError.new(options[:locale].t("errors.syntax.#{tag_name}"), options[:line])
              end

              super
            end

            def render(context)
              current_page = context.registers[:page]

              element = current_page.find_editable_element(self.current_block_name(context), @slug)

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

            def current_block_name(context)
              context['block'].try(:name)
            end

          end

        end
      end
    end
  end
end