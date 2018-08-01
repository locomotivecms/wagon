module Locomotive
  module Wagon
    module Generators
      module Site

        class Foundation < Base

          class_option :scss, type: :boolean, default: nil, required: false, desc: 'Use SCSS stylesheets?'

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

          private

          def scss?
            if options[:scss].nil?
              yes?('Do you prefer SCSS stylesheets?')
            else
              options[:scss]
            end
          end

        end

        Locomotive::Wagon::Generators::Site.register(:foundation, Foundation, %{
          A site powered by Foundation (v6.2.1).
        })
      end
    end
  end
end
