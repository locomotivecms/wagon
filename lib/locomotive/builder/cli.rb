require "thor"

module Locomotive
  module Builder
    class CLI < Thor
    
      desc "import NAME SITE_URL EMAIL PASSWORD", "Import an existing locomotive site"
      def import(name, site_url, email, password)
        say("ERROR: \"#{name}\" directory already exists", :red) and return if File.exists?(name)
        Locomotive::Builder.import(name, site_url, email, password)
      end
    
      desc "server PATH [PORT]", "Serve an existing site from the file system"
      def server(path, port = 3333)
        require "thin"
        require "locomotive/builder/server"
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)
        Thin::Server.start('0.0.0.0', port, Locomotive::Builder::Server.new(reader))
      end
    end
  end
end