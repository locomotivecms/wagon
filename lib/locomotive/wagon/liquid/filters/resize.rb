module Locomotive
  module Wagon
    module Liquid
      module Filters
        module Resize

          def resize(input, resize_string)
            Locomotive::Wagon::Dragonfly.instance.resize_url(input, resize_string)
          end

        end

        ::Liquid::Template.register_filter(Resize)

      end
    end
  end
end