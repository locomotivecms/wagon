$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'locomotive/builder/logger'
require 'locomotive/builder/version'
require 'locomotive/builder/exceptions'
require 'locomotive/builder/server'
require 'locomotive/mounter'

module Locomotive
  module Builder
    class StandaloneServer < Server

      def initialize(path)
        Locomotive::Builder::Logger.setup(path, false)

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