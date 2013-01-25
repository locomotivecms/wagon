require "locomotive/builder/server"
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'locomotive/builder/version'
require 'locomotive/builder/exceptions'
require 'locomotive/mounter'

module Locomotive
  module Builder
    class StandaloneServer < Server
      
      def initialize(path)
        # setting the logger
        logfile = File.join(path, 'log', 'mounter.log')
        FileUtils.mkdir_p(File.dirname(logfile))

        Locomotive::Mounter.logger = ::Logger.new(logfile).tap do |log|
          log.level = Logger::DEBUG
        end

        # get the reader
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)
        reader

        # run the rack app
        Bundler.require 'misc'
        
        super(reader, disable_listen: true)
      end
    end
  end
end