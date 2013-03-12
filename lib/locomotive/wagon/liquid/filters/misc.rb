module Locomotive
  module Wagon
    module Liquid
      module Filters
        module Misc

          # was called modulo at first
          def str_modulo(word, index, modulo)
            (index.to_i + 1) % modulo == 0 ? word : ''
          end

          # Get the nth element of the passed in array
          def index(array, position)
            array.at(position) if array.respond_to?(:at)
          end

          def default(input, value)
            input.blank? ? value : input
          end

        end

        ::Liquid::Template.register_filter(Misc)

      end
    end
  end
end