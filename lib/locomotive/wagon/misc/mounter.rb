module Locomotive
  module Mounter
    module Models
      class Page

        def render(context)
          mounting_point = context.registers[:mounting_point]

          template = ::Liquid::Template.parse(self.source, {
            page:           self,
            mounting_point: mounting_point
          })

          template.render(context)
        end

      end
    end
  end
end