module Locomotive
  module Wagon
    module Liquid
      module Tags
        class WithScope < ::Liquid::Block

          SlashedString = /\/[^\/]*\//
          TagAttributes = /(\w+|\w+\.\w+)\s*\:\s*(#{SlashedString}|#{::Liquid::QuotedFragment})/

          def initialize(tag_name, markup, tokens, options)
            @tag_options = HashWithIndifferentAccess.new
            markup.scan(TagAttributes) do |key, value|
              @tag_options[key] = value
            end
            super
          end

          def render(context)
            context.stack do
              context['with_scope'] = decode(@tag_options, context)
              render_all(@nodelist, context)
            end
          end

          private

          def decode(attributes, context)
            attributes.each_pair do |key, value|
              attributes[key] = (case value
              when /^true|false$/i    then value == 'true'
              when /^\/[^\/]*\/$/     then Regexp.new(value[1..-2])
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