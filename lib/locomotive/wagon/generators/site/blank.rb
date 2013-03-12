module Locomotive
  module Wagon
    module Generators
      module Site

        class Blank < Base

          def copy_sources
            directory('.', self.destination, { recursive: true }, {
              name:     self.name,
              version:  Locomotive::Wagon::VERSION
            })
          end

        end

        Locomotive::Wagon::Generators::Site.register(:blank, Blank, %{
          A blank LocomotiveCMS site with the minimal files.
        })
      end
    end
  end
end