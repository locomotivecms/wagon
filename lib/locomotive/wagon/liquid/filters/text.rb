require 'RedCloth'

module Locomotive
  module Wagon
    module Liquid
      module Filters
        module Text

          # right justify and padd a string
          def rjust(input, integer, padstr = '')
            input.to_s.rjust(integer, padstr)
          end

          # left justify and padd a string
          def ljust(input, integer, padstr = '')
            input.to_s.ljust(integer, padstr)
          end

          def underscore(input)
            input.to_s.gsub(' ', '_').gsub('/', '_').underscore
          end

          def dasherize(input)
            input.to_s.gsub(' ', '-').gsub('/', '-').dasherize
          end

          # alias newline_to_br
          def multi_line(input)
            input.to_s.gsub("\n", '<br/>')
          end

          def concat(input, *args)
            result = input.to_s
            args.flatten.each { |a| result << a.to_s }
            result
          end

          def textile(input)
            ::RedCloth.new(input).to_html
          end

        end

        ::Liquid::Template.register_filter(Text)

      end
    end
  end
end