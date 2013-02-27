module Locomotive
  module Wagon
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