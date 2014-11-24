module Locomotive
  module Wagon
    module Liquid
      module Drops
        class Site < Base
          include Scopeable

          delegate :name, :seo_title, :meta_description, :meta_keywords, to: :@_source

          def index
            @index ||= self.mounting_point.pages['index']
          end

          def pages
            liquify(*apply_scope(self.mounting_point.pages.values))
          end

          def domains
            @_source.domains
          end

        end
      end
    end
  end
end
