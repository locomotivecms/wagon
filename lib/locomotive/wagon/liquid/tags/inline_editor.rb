module Locomotive
  module Wagon
    module Liquid
      module Tags
        class InlineEditor < ::Liquid::Tag

          def render(context)
            ''
          end
        end

        ::Liquid::Template.register_tag('inline_editor', InlineEditor)
      end
    end
  end
end