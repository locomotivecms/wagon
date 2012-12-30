module Locomotive
  module Builder
    module Liquid
      module Tags
        module Editable
          class Base < ::Liquid::Block

            Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/

            def initialize(tag_name, markup, tokens, context)
              if markup =~ Syntax
                @slug = $1.gsub('\'', '')
                @options = {}
                markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
              else
                raise ::Liquid::SyntaxError.new("Syntax Error in 'editable_xxx' - Valid syntax: editable_xxx <slug>(, <options>)")
              end

              super
            end

            def render(context)
              super
            end

          end

        end
      end
    end
  end
end