module Locomotive
  module Builder
    module Liquid
      module Filters
        module Translate
          def translate(key)
            require 'pp'
            pp @context[:mounting_point].translations.inspect.force_encoding('UTF-8')
            "test"
          end
        end
        
        ::Liquid::Template.register_filter(Translate)
        
      end
    end
  end
end