$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'locomotive/wagon/logger'
require 'locomotive/wagon/version'
require 'locomotive/steam/server'
require 'locomotive/mounter'

module Locomotive
  module Wagon
    class StandaloneServer < Locomotive::Steam::Server

      def initialize(path)
        Locomotive::Common::Logger.setup(path, false)

        # get the reader
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)

        Bundler.require 'misc'

        # run the rack app
        super(reader, disable_listen: true)
      end
    end
  end
end