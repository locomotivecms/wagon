module Locomotive
  module Builder
    module Liquid
      module Tags
        module Editable
          class File < Base

          end

          ::Liquid::Template.register_tag('editable_file', File)
        end
      end
    end
  end
end