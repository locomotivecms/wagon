require_relative 'base_logger'

module Locomotive::Wagon

  class PullLogger < BaseLogger

    def initialize
      subscribe :start do |event|
        log "\n"
        log "Pulling #{event.payload[:name].camelcase}", { color: :black, background: :white }
      end

    end

    private

    def subscribe(action = nil, &block)
      _subscribe('pull', action, &block)
    end

  end

end
