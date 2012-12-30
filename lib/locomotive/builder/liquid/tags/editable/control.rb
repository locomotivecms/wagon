module Locomotive
  module Builder
    module Liquid
      module Tags
        module Editable
          class Control < Base

          end

          ::Liquid::Template.register_tag('editable_control', Control)
        end
      end
    end
  end
end