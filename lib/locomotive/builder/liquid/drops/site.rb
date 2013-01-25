module Locomotive
  module Builder
    module Liquid
      module Drops
        class Site < Base

          delegate :name, :seo_title, :meta_description, :meta_keywords, :to => '_source'

          def index
            @index ||= self.mounting_point.pages['index']
          end

          def pages
            @pages ||= liquify(*self._source.pages)
          end

        end
      end
    end
  end
end