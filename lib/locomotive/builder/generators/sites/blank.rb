module Locomotive
  module Builder
    module Generators
      module Sites

        class Blank < Locomotive::Builder::Generators::Base

          def copy_sources
            directory('.', self.destination, { recursive: true }, {
              name: self.name
            })
          end

        end

        Locomotive::Builder::Generators.register(:site, :blank, Blank, %{
          A blank LocomotiveCMS site with the minimal files.
        })
      end
    end
  end
end