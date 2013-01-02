require 'listen'

module Locomotive::Builder
  class Listen

    attr_accessor :reader

    def self.instance
      @@instance = new
    end

    def start(reader)
      self.reader = reader

      self.build_liquid_listener

      self.build_content_types_listener
    end

    protected

    def build_liquid_listener
      reloader = Proc.new do |modified, added, removed|
        reader.reload(:pages, :snippets)
      end

      path = File.join(self.reader.mounting_point.path, 'app/views')

      listener = ::Listen.to(path).filter(/\.liquid/).change(&reloader)

      # non blocking listener
      listener.start(false)
    end

    def build_content_types_listener
      # TODO
    end

  end

end