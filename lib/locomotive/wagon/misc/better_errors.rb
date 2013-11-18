require 'ostruct'

module BetterErrors
  class MiddlewareWrapper

    def initialize(app)
      @@middleware ||= BetterErrors::Middleware.new(app)
      @@middleware.instance_variable_set(:@app, app)
    end

    def call(env)
      env['action_dispatch.request.parameters'] = Rack::Request.new(env).params

      @@middleware.call(env)
    end

  end

  module FrameWithLiquidContext

    extend ActiveSupport::Concern

    included do

      attr_accessor :liquid_context

      alias_method_chain :local_variables, :liquid_context

      class << self

        alias_method_chain :from_exception, :liquid_context

      end
    end

    def local_variables_with_liquid_context
      if self.liquid_context
        scope = self.liquid_context.scopes.last.clone

        scope.delete_if { |k, _| %w(models contents params session).include?(k) }.tap do |_scope|
          _scope['site'] = _scope['site'].send(:_source).to_hash
          _scope['page'] = _scope['page'].to_hash.delete_if { |k, _| %w(template).include?(k) }
        end
      else
        self.local_variables_without_liquid_context
      end
    rescue Exception => e
      puts "[BetterError] Fatal error: #{e.message}".red
      puts e.backtrace.join("\n")
      {}
    end

    module ClassMethods

      def from_exception_with_liquid_context(exception)
        from_exception_without_liquid_context(exception).tap do |list|
          if exception.respond_to?(:liquid_context)
            list.first.liquid_context = exception.liquid_context
          end
        end
      end

    end
  end

  class StackFrame
    include FrameWithLiquidContext
  end

end