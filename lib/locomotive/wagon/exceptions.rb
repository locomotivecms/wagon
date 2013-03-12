module Locomotive
  module Wagon

    class DefaultException < ::Exception

      def initialize(message = nil, parent_exception = nil)
        self.log_backtrace(parent_exception) if parent_exception

        super(message)
      end

      protected

      def log_backtrace(parent_exception)
        full_error_message = "#{parent_exception.message}\n\t"
        full_error_message += parent_exception.backtrace.join("\n\t")
        full_error_message += "\n\n"
        Locomotive::Wagon::Logger.fatal full_error_message
      end

    end

    class MounterException < DefaultException
    end

    class GeneratorException < DefaultException

      def log_backtrace(parent_exception)
        # Logger not initialized at this step
      end

    end

  end
end
