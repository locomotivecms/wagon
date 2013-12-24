module Locomotive
  module Wagon
    module Generators
      module Site

        class Blank < Base

          def choose_haml_over_html
            if yes?('Do you prefer HAML templates ?')
              remove_file File.join(self.destination, 'app/views/pages/index.liquid')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid')
            else
              remove_file File.join(self.destination, 'app/views/pages/index.liquid.haml')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid.haml')
            end
          end
        end

        Locomotive::Wagon::Generators::Site.register(:blank, Blank, %{
          A blank LocomotiveCMS site with the minimal files.
        })
      end
    end
  end
end