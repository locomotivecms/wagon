module Locomotive::Wagon

  class PushLogger

    def initialize
      subscribe 'site_created' do |event|
        log "We created your site with the following handle: #{event.payload[:site].handle}", { mode: :bold }
      end

      subscribe :start do |event|
        log "\n"
        log "Pushing #{event.payload[:name].camelcase}", { color: :black, background: :white }
      end

      subscribe :persist do |event|
        log "persisting #{event.payload[:label]}", :white, 2, true
      end

      subscribe :skip_persisting do |event|
        log ' [' + 'skip'.colorize(:yellow) + ']'
      end

      subscribe :persist_with_success do |event|
        log ' [' + 'done'.colorize(:green) + ']'
      end

      subscribe :persist_with_error do |event|
        log ' [' + 'failed'.colorize(:red) + ']'
        log event.payload[:message], :red, 4
      end
    end

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

    def subscribe(action = nil, &block)
      name = ['wagon', 'push', [*action]].flatten.compact.join('.')

      ActiveSupport::Notifications.subscribe(name) do |*args|
        event = ActiveSupport::Notifications::Event.new *args
        yield(event)
      end
    end

  end

end
