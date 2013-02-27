module Locomotive
  module Wagon

    class Logger

      attr_accessor :logger, :logfile_path, :stdout

      def initialize
        self.logger = nil
      end

      # Setup the single instance of the ruby logger.
      #
      # @param [ String ] path The path to the log file (default: log/wagon.log)
      # @param [ Boolean ] stdout Instead of having a file, log to the standard output
      #
      def setup(path, stdout = false)
        require 'logger'

        self.stdout = stdout

        self.logfile_path = File.expand_path(File.join(path, 'log', 'wagon.log'))
        FileUtils.mkdir_p(File.dirname(logfile_path))

        out = self.stdout ? STDOUT : self.logfile_path

        self.logger = ::Logger.new(out).tap do |log|
          log.level     = ::Logger::DEBUG
          log.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
          end
        end
      end

      def self.instance
        @@instance ||= self.new
      end

      def self.setup(path, stdout = false)
        self.instance.setup(path, stdout)
      end

      class << self
        %w(debug info warn error fatal unknown).each do |name|
          define_method(name) do |message|
            self.instance.logger.send(name.to_sym, message)
          end
        end
      end

    end

  end
end