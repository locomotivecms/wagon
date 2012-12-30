module Locomotive
  module Builder
    module Liquid
      module Drops
        class ContentEntry < Base

          delegate :_permalink, :seo_title, :meta_keywords, :meta_description, :to => '_source'

          def before_method(meth)
            return '' if @_source.nil?

            if not @@forbidden_attributes.include?(meth.to_s)
              value = @_source.send(meth)
            end
          end

          def _permalink
            @_source._permalink.parameterize
          end

          def highlighted_field_value
            @_source.highlighted_field_value
          end

        end
      end
    end
  end
end