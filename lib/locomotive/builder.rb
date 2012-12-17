require "locomotive/builder/version"
require "locomotive/mounter"

module Locomotive
  module Builder
    def self.import(name, site_url, email, password)
      reader = Locomotive::Mounter::Reader::Api.instance
      reader.run!(uri: "#{site_url.chomp('/')}/locomotive/api", email: email, password: password)
      writer = Locomotive::Mounter::Writer::FileSystem.instance
      writer.run!(mounting_point: reader.mounting_point, target_path: name)
    end
  end
end