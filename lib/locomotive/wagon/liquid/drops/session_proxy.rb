module Locomotive
  module Wagon
    module Liquid
      module Drops

        class SessionProxy < ::Liquid::Drop

          def before_method(meth)
            request = @context.registers[:request]
            request.session[meth.to_sym]
          end

        end

      end
    end
  end
end