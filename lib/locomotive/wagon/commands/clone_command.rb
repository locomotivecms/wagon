module Locomotive::Wagon

  class CloneCommand < Struct.new(:name, :path, :options, :shell)

    def self.clone(name, path, options, shell)
      new(name, path, options, shell).clone
    end

    def clone
      # create an empty site with the minimal settings
      create_site

      # pull the pages, content_types, basically any resources from the remote site
      pull_site
    end

    def connection_info
      options.symbolize_keys.slice(:host, :handle, :email, :api_key, :password)
    end

    private

    def create_site
      require 'locomotive/wagon/generators/site'
      generator = Locomotive::Wagon::Generators::Site::Cloned
      generator.start [name, path, true, connection_info]
    end

    def pull_site
      raise 'TODO: call the pull command'
    end

  end

end
