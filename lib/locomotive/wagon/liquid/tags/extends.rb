module Locomotive
  module Wagon
    module Liquid
      module Tags
        class Extends < ::Liquid::Extends

          def parse_parent_template
            mounting_point = @options[:mounting_point]

            page = if @template_name == 'parent'
              @options[:page].parent
            else
              mounting_point.pages[@template_name]
            end

            ::Liquid::Template.parse(page.source, { mounting_point: mounting_point, page: page })
          end

        end

        ::Liquid::Template.register_tag('extends', Extends)
      end
    end
  end
end