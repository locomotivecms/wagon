require "thor"

module Steam
  class CLI < Thor
    
    desc "import NAME SITE_URL EMAIL PASSWORD", "Import an existing locomotive site"
    def import(name, site_url, email, password)
      say("ERROR: \"#{name}\" directory already exists", :red) and return if File.exists?(name)
      Steam.import(name, site_url, email, password)
    end
    
    desc "server PATH [PORT]", "Serve an existing site from the file system"
    def server(path, port = 3333)
      require "thin"
      require "steam/server"
      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: path)
      Thin::Server.start('0.0.0.0', port, Steam::Server.new(reader))
    end
  end
end