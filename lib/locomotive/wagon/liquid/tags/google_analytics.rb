module Locomotive
  module Wagon
    module Liquid
      module Tags
        class GoogleAnalytics < ::Liquid::Tag

          Syntax = /(#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @account_id = $1.gsub('\'', '')
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'google_analytics' - Valid syntax: google_analytics <account_id>")
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