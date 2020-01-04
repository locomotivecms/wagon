module Locomotive
  module Wagon
    module Generators
      module Site

        # Template used when the remote LocomotiveCMS site is cloned
        # in order to have the minimal files.
        class Cloned < Base

          argument :connection_info

          def copy_sources
            copy_sources_from_generator(generator_name: 'cloned', options: self.connection_info)
          end

        end
      end
    end
  end
end
