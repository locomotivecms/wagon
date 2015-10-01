require_relative 'base_logger'

module Locomotive::Wagon

  class PushLogger < BaseLogger

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

      subscribe :warning do |event|
        log "Warning: #{event.payload[:message]}", :yellow
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

    def subscribe(action = nil, &block)
      _subscribe('push', action, &block)
    end

  end

end
