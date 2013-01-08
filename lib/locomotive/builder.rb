require "locomotive/builder/version"
require "locomotive/mounter"

module Locomotive
  module Builder

    def self.pull(path, site_url, email, password)
      reader = Locomotive::Mounter::Reader::Api.instance
      reader.run!(uri: "#{site_url.chomp('/')}/locomotive/api", email: email, password: password)
      writer = Locomotive::Mounter::Writer::FileSystem.instance
      writer.run!(mounting_point: reader.mounting_point, target_path: path)
    end

    def self.push(path, site_url, email, password)
      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: path)
      writer = Locomotive::Mounter::Writer::Api.instance
      writer.run!(mounting_point: reader.mounting_point, uri: "#{site_url.chomp('/')}/locomotive/api", email: email, password: password)
    end

  end
end