module Locomotive::Wagon

  class BaseLogger

    private

    def log(message, color = nil, ident = nil, print = false)
      ident = ' ' * (ident || 0)

      message = "#{ident}#{message.gsub("\n", "\n" + ident)}"
      message = message.colorize(color) if color

      if print
        print message
      else
        puts message
      end
    end

    def _subscribe(type, action = nil, &block)
      name = ['wagon', type, [*action]].flatten.compact.join('.')

      ActiveSupport::Notifications.subscribe(name) do |*args|
        event = ActiveSupport::Notifications::Event.new *args
        yield(event)
      end
    end

  end

end
