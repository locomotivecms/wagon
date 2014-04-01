require 'thor/shell/color'

class Thor
  module Shell
    class ForceColor < ::Thor::Shell::Color

      protected

        def can_display_colors?
          true
        end

    end
  end
end