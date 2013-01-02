require 'listen'

module Locomotive::Builder
  class Listen

    attr_accessor :reader

    def self.instance
      @@instance = new
    end

    def start(reader)
      self.reader = reader

      self.definitions.each do |definition|
        self.apply(definition)
      end
    end

    def definitions
      [
        ['config', /\.yml/, [:site, :content_types, :pages, :snippets, :content_entries]],
        ['app/views', /\.liquid/, [:pages, :snippets]],
        ['app/content_types', /\.yml/, [:content_types, :content_entries]],
        ['data', /\.yml/, :content_entries]
      ]
    end

    protected

    def apply(definition)
      reloader = Proc.new do |modified, added, removed|
        reader.reload(definition.last)
      end

      filter  = definition[1]
      path    = File.join(self.reader.mounting_point.path, definition.first)

      listener = ::Listen.to(path).filter(filter).change(&reloader)

      # non blocking listener
      listener.start(false)
    end

  end

end