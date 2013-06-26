module Locomotive
  module Wagon
    module Liquid
      module Tags
        module Editable
          class Text < Base

          end

          ::Liquid::Template.register_tag('editable_text', Text)
        end
      end
    end
  end
end