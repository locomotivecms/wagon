$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'locomotive/wagon/logger'
require 'locomotive/wagon/version'
require 'locomotive/wagon/exceptions'
require 'locomotive/wagon/server'
require 'locomotive/mounter'

module Locomotive
  module Wagon
    class StandaloneServer < Server

      def initialize(path)
        Locomotive::Wagon::Logger.setup(path, false)

        # get the reader
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)
        reader

        Bundler.require 'misc'

        # run the rack app
        super(reader, disable_listen: true)
      end
    end
  end
end