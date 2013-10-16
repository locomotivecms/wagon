module Locomotive
  module Wagon
    module Liquid
      module Tags
        class PathTo < LinkTo

          Syntax = /(#{::Liquid::Expression}+)(#{::Liquid::TagAttributes}?)/

          def render(context)
            if page = self.retrieve_page_from_handle(context)
              self.public_page_url(context, page)
            else
              raise Liquid::PageNotTranslated.new(%{[path_to] Unable to find a page for the #{@handle}. Wrong handle or missing template for your content.})
            end
          end

        end

        ::Liquid::Template.register_tag('path_to', PathTo)
      end
    end
  end
end