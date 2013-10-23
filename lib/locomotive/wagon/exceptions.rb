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

    class RendererException < DefaultException

      attr_accessor :name, :template, :liquid_context

      def initialize(exception, name, template, liquid_context)
        self.name, self.template, self.liquid_context = name, template, liquid_context

        self.log_page_into_backtrace(exception)

        super(exception.message)

        self.set_backtrace(exception.backtrace)
      end

      def log_page_into_backtrace(exception)
        line = self.template.line_offset
        line += (exception.respond_to?(:line) ? exception.line || 0 : 0) + 1

        message = "#{self.template.filepath}:#{line}:in `#{self.name}'"

        Locomotive::Wagon::Logger.fatal "[ERROR] #{exception.message} - #{message}\n".red

        exception.backtrace.unshift message
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
