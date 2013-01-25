module Locomotive
  module Builder
    module Liquid
      module Filters
        module Translate

          def translate(key)
            translations  = @context.registers[:mounting_point].translations

            translations[key.to_s].try(:get, Locomotive::Mounter.locale)
          end

        end

        ::Liquid::Template.register_filter(Translate)

      end
    end
  end
end