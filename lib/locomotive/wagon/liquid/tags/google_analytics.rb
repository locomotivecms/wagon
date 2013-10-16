module Locomotive
  module Wagon
    module Liquid
      module Tags
        class GoogleAnalytics < ::Liquid::Tag

          Syntax = /(#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, options)
            if markup =~ Syntax
              @account_id = $1.gsub('\'', '')
            else
              raise ::Liquid::SyntaxError.new(options[:locale].t("errors.syntax.google_analytics"), options[:line])
            end

            super
          end

          def render(context)
           "<!-- google analytics for #{@account_id} -->"
          end
        end

        ::Liquid::Template.register_tag('google_analytics', GoogleAnalytics)
      end
    end
  end
end