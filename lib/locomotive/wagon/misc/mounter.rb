module Locomotive
  module Mounter
    module Models
      class Page

        def render(context)
          self.parse(context).render(context)
        end

        protected

        def parse(context)
          options =  {
            page:           self,
            mounting_point: context.registers[:mounting_point],
            error_mode:     :strict,
            count_lines:    true
          }

          begin
            template = ::Liquid::Template.parse(self.source, options)
          rescue Liquid::SyntaxError => e
            # do it again on the raw source instead so that the error line matches
            # the source file.
            ::Liquid::Template.parse(self.template.raw_source, options)
          end
        end

      end
    end
  end
end