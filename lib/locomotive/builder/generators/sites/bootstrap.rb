module Locomotive
  module Builder
    module Generators
      module Sites

        class Bootstrap < Locomotive::Builder::Generators::Base

          def copy_sources
            directory('.', self.destination, { recursive: true }, {
              name: self.name
            })
          end

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

        Locomotive::Builder::Generators.register(:site, :bootstrap, Bootstrap, %{
          A LocomotiveCMS site powered by Twitter boostrap.
        })
      end
    end
  end
end