module Locomotive
  module Wagon
    module Generators
      module Site

        class Bootstrap < Base

          def copy_sources
            # first copy the sources from the blank template
            copy_sources_from_generator(generator_name: 'blank')

            # finally, add/erase files specific to Bootstrap
            copy_sources_from_generator(options: { force: true })
          end

        end

        Locomotive::Wagon::Generators::Site.register(:bootstrap, Bootstrap, %{
          A site powered by Bootstrap 4 and Webpack.
        })
      end
    end
  end
end
