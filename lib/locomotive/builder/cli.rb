require "thor"

module Locomotive
  module Builder
    class CLI < Thor

      desc "pull NAME SITE_URL EMAIL PASSWORD", "Pull an existing LocomotiveCMS site powered by the engine"
      def pull(name, site_url, email, password)
        say("ERROR: \"#{name}\" directory already exists", :red) and return if File.exists?(name)
        Locomotive::Builder.pull(name, site_url, email, password)
      end

      desc "push PATH SITE_URL EMAIL PASSWORD", "Push a site created by the builder to a remote LocomotiveCMS engine"
      def push(path, site_url, email, password)
        Locomotive::Builder.push(path, site_url, email, password)
      end

      desc "server PATH [PORT]", "Serve an existing site from the file system"
      def server(path, port = 3333)
        require "thin"
        require "locomotive/builder/server"
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)

        server = Thin::Server.new('0.0.0.0', port, Locomotive::Builder::Server.new(reader))
        # server.threaded = true
        server.start
      end
    end
  end
end