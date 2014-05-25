require 'socket'

module Locomotive
  module Wagon

    class TcpPort

      MAX_ATTEMPTS = 1000

      def initialize(host, from)
        @host = host
        @from = from
      end

      def first
        current = @from.to_i
        max     = current + MAX_ATTEMPTS
        while open_port(@host, current)
          current += 1
          raise "No available ports from #{@from}" if current >= max
        end
        current.to_s
      end

      private

      def open_port(host, port)
        sock = Socket.new(:INET, :STREAM)
        raw = Socket.sockaddr_in(port, host)
        sock.connect(raw)
        sock.close if sock
        true
      rescue Errno::ECONNREFUSED
        false
      rescue Errno::ETIMEDOUT
        false
      end

    end

  end
end