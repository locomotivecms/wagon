module Locomotive
  module Wagon
    module Generators
      module Site

        class Foundation5 < Base

          may_use_haml
          may_use_scss

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

          def choose_scss_over_css
            if scss?
              remove_file File.join(self.destination, 'public/stylesheets/application.css')
              remove_file File.join(self.destination, 'public/stylesheets/foundation.css')
              remove_file File.join(self.destination, 'public/stylesheets/normalize.css')
            else
              remove_dir File.join(self.destination, 'public/stylesheets/foundation')
              remove_file File.join(self.destination, 'public/stylesheets/application.css.scss')
              remove_file File.join(self.destination, 'public/stylesheets/foundation.css.scss')
              remove_file File.join(self.destination, 'public/stylesheets/normalize.css.scss')
            end
          end

          def bundle_install
            super
          end

        end

        Locomotive::Wagon::Generators::Site.register(:foundation5, Foundation5, %{
          A site powered by Foundation (v5.2.3.0).
        })
      end
    end
  end
end