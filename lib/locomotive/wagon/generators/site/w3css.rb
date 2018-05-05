module Locomotive
  module Wagon
    module Generators
      module Site

        class W3css < Base

          may_use_haml
          # may_use_scss

          def choose_haml_over_html
            if haml?
              remove_file File.join(self.destination, 'app/views/pages/layouts/default.liquid')
              remove_file File.join(self.destination, 'app/views/pages/layouts/simple.liquid')
              remove_file File.join(self.destination, 'app/views/pages/index.liquid')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid')
              remove_file File.join(self.destination, 'app/views/snippets/nav.liquid')
              remove_file File.join(self.destination, 'app/views/snippets/footer.liquid')
            else
              remove_file File.join(self.destination, 'app/views/pages/layouts/default.liquid.haml')
              remove_file File.join(self.destination, 'app/views/pages/layouts/simple.liquid.haml')
              remove_file File.join(self.destination, 'app/views/pages/index.liquid.haml')
              remove_file File.join(self.destination, 'app/views/pages/404.liquid.haml')
              remove_file File.join(self.destination, 'app/views/snippets/nav.liquid.haml')
              remove_file File.join(self.destination, 'app/views/snippets/footer.liquid.haml')
            end
          end

          # def choose_scss_over_css
          #   if scss?
          #     remove_file File.join(self.destination, 'public/stylesheets/application.css')
          #     remove_file File.join(self.destination, 'public/stylesheets/w3css.css')
          #   else
          #     remove_dir File.join(self.destination, 'public/stylesheets/w3css')
          #     remove_file File.join(self.destination, 'public/stylesheets/application.scss')
          #     remove_file File.join(self.destination, 'public/stylesheets/w3css.scss')
          #   end
          # end

          def bundle_install
            super
          end

        end

        Locomotive::Wagon::Generators::Site.register(:w3css, W3css, %{
          A site powered by w3css (v4.03).
        })
      end
    end
  end
end
