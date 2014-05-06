module Locomotive
  module Wagon
    module Generators
      module Site

        class LineCase < Base

          def bundle_install
            super
          end

        end

        Locomotive::Wagon::Generators::Site.register(:line_case, LineCase, %{
          A simple portfolio site.
        })
      end
    end
  end
end