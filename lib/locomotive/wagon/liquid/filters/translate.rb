module Locomotive
  module Wagon
    module Liquid
      module Filters
        module Translate

          def translate(key, locale = nil)
            translation = @context.registers[:mounting_point].translations[key.to_s]

            if translation
              translation.get(locale) || translation.get(Locomotive::Mounter.locale.to_s)
            else
              "[unknown translation key: #{key}]"
            end
          end

        end

        ::Liquid::Template.register_filter(Translate)

      end
    end
  end
end