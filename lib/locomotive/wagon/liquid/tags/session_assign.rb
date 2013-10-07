module Locomotive
  module Wagon
    module Liquid
      module Tags

        # Assign sets a variable in your session.
        #
        #   {% session_assign foo = 'monkey' %}
        #
        # You can then use the variable later in the page.
        #
        #   {{ session.foo }}
        #
        class SessionAssign < ::Liquid::Tag
          Syntax = /(#{::Liquid::VariableSignature}+)\s*=\s*(#{::Liquid::QuotedFragment}+)/

          def initialize(tag_name, markup, tokens, options)
            if markup =~ Syntax
              @to = $1
              @from = $2
            else
              raise ::Liquid::SyntaxError.new(options[:locale].t("errors.syntax.session_assign"), options[:line])
            end

            super
          end

          def render(context)
            request = context.registers[:request]

            request.session[@to.to_sym] = context[@from]
            ''
          end

        end

        ::Liquid::Template.register_tag('session_assign', SessionAssign)
      end
    end
  end
end