module Locomotive
  module Wagon
    module Liquid
      module Tags

        class Snippet < ::Liquid::Include

          def render(context)
            name    = @template_name.gsub(/[\"\']/, '')
            snippet = context.registers[:mounting_point].snippets[name.gsub('-', '_')]

            raise ::Liquid::StandardError.new("Unknown snippet \"#{name}\"") if snippet.nil?

            partial   = self.parse_template(snippet)

            variable  = context[@variable_name || @template_name[1..-2]]

            context.stack do
              @attributes.each do |key, value|
                context[key] = context[value]
              end

              output = (if variable.is_a?(Array)
                variable.collect do |variable|
                  context[@template_name[1..-2]] = variable
                  partial.render(context)
                end
              else
                context[@template_name[1..-2]] = variable
                partial.render(context)
              end)

              Locomotive::Wagon::Logger.info "  Rendered snippet #{name}"

              output
            end
          end

          protected

          def parse_template(snippet)
            begin
              ::Liquid::Template.parse(snippet.source)
            rescue ::Liquid::Error => e
              # do it again on the raw source instead so that the error line matches
              # the source file.
              begin
                ::Liquid::Template.parse(snippet.template.raw_source)
              rescue ::Liquid::Error => e
                e.backtrace.unshift "#{snippet.template.filepath}:#{e.line + 1}:in `#{snippet.name}'"
                e.line = self.line - 1
                raise e
              end
            end
          end

        end

        ::Liquid::Template.register_tag('include', Snippet)
      end
    end
  end
end