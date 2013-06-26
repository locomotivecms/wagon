module Locomotive
  module Wagon
    module Liquid
      module Tags
        module Editable
          class ShortText < Base

            def render(context)
              Locomotive::Wagon::Logger.warn "  [#{self.current_block_name(context)}/#{@slug}] The editable_{short|long}_text tags are deprecated. Use editable_text instead.".colorize(:orange)
              super(context)
            end

          end

          ::Liquid::Template.register_tag('editable_short_text', ShortText)
        end
      end
    end
  end
end