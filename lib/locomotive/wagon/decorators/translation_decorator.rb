module Locomotive
  module Wagon

    class TranslationDecorator < SimpleDelegator

      include ToHashConcern

      def id
        key
      end

      def __attributes__
        %i(key values)
      end

    end

  end
end
