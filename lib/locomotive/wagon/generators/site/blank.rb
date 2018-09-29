module Locomotive
  module Wagon
    module Generators
      module Site

        class Blank < Base

        end

        Locomotive::Wagon::Generators::Site.register(:blank, Blank, %{
          A blank site with the minimal files.
        })
      end
    end
  end
end
