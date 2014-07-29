module Locomotive
  module Wagon
    module Generators
      module Site

        class Bootstrap2 < Base

          may_use_haml

          def choose_haml_over_html
            if haml?
              remove_file File.join(self.destination, 'app/views/pages/index.liquid')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid')
              remove_file File.join(self.destination, 'app/views/snippets/footer.liquid')
            else
              remove_file File.join(self.destination, 'app/views/pages/index.liquid.haml')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid.haml')
              remove_file File.join(self.destination, 'app/views/snippets/footer.liquid.haml')
            end
          end

          def bundle_install
            super
          end

        end

        Locomotive::Wagon::Generators::Site.register(:bootstrap2, Bootstrap2, %{
          A site with Twitter Bootstrap (v2.3.2) and Font Awesome (v3.2.1).
        })
      end
    end
  end
end