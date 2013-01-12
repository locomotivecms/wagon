require 'locomotive/builder/version'

module Locomotive
  module Builder

    # Create a site from a site generator.
    #
    # @param [ String ] name The name of the site (underscored)
    # @param [ String ] path The destination path of the site
    # @param [ Object ] generator The wrapping class of the generator itself
    #
    def self.init(name, path, generator)
      generator.klass.start [name, path]
    end

    # Start the thin server which serves the LocomotiveCMS site from the system.
    #
    # @param [ String ] path The path of the site
    # @param [ Hash ] options The options for the thin server (host, port)
    #
    def self.serve(path, options)
      require "thin"
      require "locomotive/builder/server"
      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: path)

      server = Thin::Server.new(options[:host], options[:port], Locomotive::Builder::Server.new(reader))
      # server.threaded = true # TODO: make it an option ?
      server.start
    end

    # TODO
    def self.pull(path, site_url, email, password)
      require 'locomotive/mounter'

      reader = Locomotive::Mounter::Reader::Api.instance
      reader.run!(uri: "#{site_url.chomp('/')}/locomotive/api", email: email, password: password)
      writer = Locomotive::Mounter::Writer::FileSystem.instance
      writer.run!(mounting_point: reader.mounting_point, target_path: path)
    end

    # TODO
    def self.push(path, site_url, email, password)
      require 'locomotive/mounter'

      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: path)
      writer = Locomotive::Mounter::Writer::Api.instance
      writer.run!(mounting_point: reader.mounting_point, uri: "#{site_url.chomp('/')}/locomotive/api", email: email, password: password)
    end

  end
end