module Locomotive
  module Wagon
    module Liquid
      module Tags

        class WithScope < Solid::Block

          OPERATORS = %w(all exists gt gte in lt lte ne nin size near within)

          SYMBOL_OPERATORS_REGEXP = /(\w+\.(#{OPERATORS.join('|')})){1}\s*\:/

          # register the tag
          tag_name :with_scope

          def initialize(tag_name, arguments_string, tokens, context = {})
            # convert symbol operators into valid ruby code
            arguments_string.gsub!(SYMBOL_OPERATORS_REGEXP, ':"\1" =>')

            super(tag_name, arguments_string, tokens, context)
          end

          def display(options = {}, &block)
            current_context.stack do
              current_context['with_scope'] = self.decode(options)
              yield
            end
          end

          protected

          def decode(options)
            HashWithIndifferentAccess.new.tap do |hash|
              options.each do |key, value|
                hash[key] = (case value
                  # regexp inside a string
                when /^\/[^\/]*\/$/ then Regexp.new(value[1..-2])
                else
                  value
                end)
              end
            end
          end
        end

      end
    end
  end
end