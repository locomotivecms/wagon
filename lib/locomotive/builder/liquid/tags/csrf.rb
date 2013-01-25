module Locomotive
  module Builder
    module Liquid
      module Tags
        module Csrf

          class Param < ::Liquid::Tag

            def render(context)
              %{<input type="hidden" name="authenticity_token" value="helloworld" />}
            end

          end

          class Meta < ::Liquid::Tag

            def render(context)
              %{
                <meta name="csrf-param" content="authenticity_token" />
                <meta name="csrf-token" content="helloworld" />
              }
            end

          end

        end

        ::Liquid::Template.register_tag('csrf_param', Csrf::Param)
        ::Liquid::Template.register_tag('csrf_meta', Csrf::Meta)

      end
    end
  end
end