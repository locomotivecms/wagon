module Locomotive
  module Wagon
    module Liquid
      module Tags
        class WithScope < ::Liquid::Block

          def initialize(tag_name, markup, tokens, context)
            @options = {}

            markup.scan(::Liquid::TagAttributes) do |key, value|
              @options[key] = value
            end

            super
          end

          def render(context)
            context.stack do
              context['with_scope'] = decode(@options, context)
              render_all(@nodelist, context)
            end
          end

          private

          def decode(attributes, context)
            attributes.each_pair do |key, value|
              attributes[key] = (case value
              when /^true|false$/i then value == 'true'
              when /^[0-9]+$/ then value.to_i
              when /^["|'](.+)["|']$/ then $1.gsub(/^["|']/, '').gsub(/["|']$/, '')
              else
                context[value] || value
              end)
            end
          end
        end

        ::Liquid::Template.register_tag('with_scope', WithScope)
      end
    end
  end
end