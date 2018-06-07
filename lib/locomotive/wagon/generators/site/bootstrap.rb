module Locomotive
  module Wagon
    module Generators
      module Site

        class Bootstrap < Base

          may_use_scss

          def choose_scss_over_css
            if scss?
              remove_file File.join(self.destination, 'public/stylesheets/application.css')
              remove_file File.join(self.destination, 'public/stylesheets/bootstrap.css')
            else
              remove_dir File.join(self.destination, 'public/stylesheets/bootstrap')
              remove_file File.join(self.destination, 'public/stylesheets/application.scss')
              remove_file File.join(self.destination, 'public/stylesheets/bootstrap.scss')
            end
          end

          def bundle_install
            super
          end

        end

        Locomotive::Wagon::Generators::Site.register(:bootstrap, Bootstrap, %{
          A site powered by Bootstrap (v3.3.5).
        })
      end
    end
  end
end
