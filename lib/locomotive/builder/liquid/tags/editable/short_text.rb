module Locomotive
  module Builder
    module Liquid
      module Tags
        module Editable
          class ShortText < Base

          end

          ::Liquid::Template.register_tag('editable_short_text', ShortText)
        end
      end
    end
  end
end