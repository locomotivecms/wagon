module Locomotive
  module Wagon
    module Generators
      module Site

        class Bootstrap3 < Base

          def choose_haml_over_html
            if yes?('Do you prefer HAML templates ?')
              remove_file File.join(self.destination, 'app/views/pages/index.liquid')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid')
              remove_file File.join(self.destination, 'app/views/snippets/footer.liquid')
            else
              remove_file File.join(self.destination, 'app/views/pages/index.liquid.haml')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid.haml')
              remove_file File.join(self.destination, 'app/views/snippets/footer.liquid.haml')
            end
          end

        end

        Locomotive::Wagon::Generators::Site.register(:bootstrap3, Bootstrap3, %{
          A LocomotiveCMS site powered by Twitter bootstrap (v3.0.0).
        })
      end
    end
  end
end