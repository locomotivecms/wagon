module Locomotive
  module Wagon

    class EditableElementDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern

      def __attributes__
        %i(block slug content)
      end

    end

  end
end
