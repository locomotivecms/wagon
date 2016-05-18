module Locomotive
  module Wagon
    module Generators
      module Site

        class Foundation < Base

          may_use_haml
          may_use_scss

          def choose_haml_over_html
            if haml?
              remove_file File.join(self.destination, 'app/views/pages/index.liquid')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid')
            else
              remove_file File.join(self.destination, 'app/views/pages/index.liquid.haml')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid.haml')
            end
          end

          def choose_scss_over_css
            if scss?
              remove_file File.join(self.destination, 'public/stylesheets/app.css')
              remove_file File.join(self.destination, 'public/stylesheets/foundation.min.css')
            else
              remove_dir File.join(self.destination, 'public/stylesheets/foundation6')
              remove_file File.join(self.destination, 'public/stylesheets/app.scss')
              remove_file File.join(self.destination, 'public/stylesheets/_settings.scss')
            end
          end

          def bundle_install
            super
          end

        end

        Locomotive::Wagon::Generators::Site.register(:foundation, Foundation, %{
          A site powered by Foundation (v 6.2.1).
        })
      end
    end
  end
end
