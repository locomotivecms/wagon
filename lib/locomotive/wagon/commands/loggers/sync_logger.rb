require_relative 'base_logger'

module Locomotive::Wagon

  class SyncLogger < BaseLogger

    def initialize
      subscribe :start do |event|
        log "\n"
        log "Syncing #{event.payload[:name].camelcase}", { color: :black, background: :white }
      end

    end

    private

    def subscribe(action = nil, &block)
      _subscribe('sync', action, &block)
    end

  end

end
