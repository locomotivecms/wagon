module Locomotive
  module Builder
    module Liquid
      module Drops
        class Page < Base

          delegate :title, :slug, :fullpath, :parent, :depth, :seo_title, :redirect_url, :meta_description, :meta_keywords, :to => '_source'

          def children
            @children ||= liquify(*@_source.children)
          end

          def published?
            @_source.published?
          end

          def redirect?
            self._source.redirect?
          end

          def breadcrumbs
            # TODO
            ''
          end

          def listed?
            @_source.listed?
          end

        end
      end
    end
  end
end