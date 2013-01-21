module Locomotive
  module Builder

    class DefaultException < ::Exception

      def initialize(message = nil)
        # no specific treatment for now
        super
      end

    end

    class MounterException < DefaultException
    end

  end
end
