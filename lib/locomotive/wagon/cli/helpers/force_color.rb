module Locomotive
  module Wagon
    module CLI
      module Helpers
        module ForceColor

          def force_color_if_asked(options)
            if options[:force_color]
              require 'locomotive/wagon/misc/thor'
              self.shell = Thor::Shell::ForceColor.new
            end
          end
        end
      end
    end
  end
end