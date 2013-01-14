module Locomotive
  module Builder
    module Generators
      module Site

        class Blank < Base

          def copy_sources
            directory('.', self.destination, { recursive: true }, {
              name: self.name
            })
          end

        end

        Locomotive::Builder::Generators::Site.register(:blank, Blank, %{
          A blank LocomotiveCMS site with the minimal files.
        })
      end
    end
  end
end