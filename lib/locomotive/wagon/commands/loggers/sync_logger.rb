require_relative 'base_logger'

module Locomotive::Wagon

  class SyncLogger < BaseLogger

    def initialize
      subscribe :start do |event|
        log "\n"
        log "Syncing #{event.payload[:name].camelcase}", { color: :black, background: :white }
      end

      subscribe :writing do |event|
        log "writing #{event.payload[:label]}", :white, 2, true
      end

      subscribe :write_with_success do |event|
        log ' [' + 'done'.colorize(:green) + ']'
      end
    end

    private

    def subscribe(action = nil, &block)
      _subscribe('sync', action, &block)
    end

  end

end
