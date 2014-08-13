module Locomotive
  module Wagon
    module Liquid
      module Tags

        # Fetch a page from its handle and assign it to a liquid variable.
        #
        # Usage:
        #
        # {% fetch_page 'about_us' as a_page %}
        # <p>{{ a_page.title }}</p>
        #
        class FetchPage < ::Liquid::Tag

          Syntax = /(#{::Liquid::VariableSignature}+)\s+as\s+(#{::Liquid::VariableSignature}+)/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @handle = $1
              @var = $2
            else
              raise SyntaxError.new("Syntax Error in 'fetch_page' - Valid syntax: fetch_page page_handle as variable")
            end

            super
          end

          def render(context)
            mounting_point = context.registers[:mounting_point]
            context.scopes.last[@var] = mounting_point.pages.values.find { |_page| _page.handle == @handle }
            ''
          end

        end

        ::Liquid::Template.register_tag('fetch_page', FetchPage)
      end

    end
  end
end