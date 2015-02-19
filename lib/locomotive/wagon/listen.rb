require 'listen'

module Locomotive::Wagon
  class Listen

    attr_accessor :reader

    def self.instance
      @@instance = new
    end

    def start(reader)
      @reader = reader

      self.definitions.each do |definition|
        self.apply(definition)
      end
    end

    def definitions
      [
        ['config', /\.yml/, [:site, :content_types, :pages, :snippets, :content_entries, :translations]],
        ['app/views', %r{(pages|snippets)/(.+\.liquid).*}, [:pages, :snippets]],
        ['app/content_types', /\.yml/, [:content_types, :content_entries]],
        ['data', /\.yml/, :content_entries],
        ['public', %r{((stylesheets|javascripts)/(.+\.(css|js))).*}, []]
      ]
    end

    protected

    def apply(definition)
      reloader = Proc.new do |modified, added, removed|
        resources = [*definition.last]
        names     = resources.map { |n| "\"#{n}\"" }.join(', ')

        unless resources.empty?
          Locomotive::Wagon::Logger.info "* Reloaded #{names} at #{Time.now}"

          begin
            reader.reload(resources)
          rescue Exception => e
            Locomotive::Wagon::MounterException.new('Unable to reload', e)
          end
        end
      end

      filter  = definition[1]
      path    = File.join(self.reader.mounting_point.path, definition.first)
      path    = File.expand_path(path)

      listener = ::Listen.to(path, {only: filter, force_polling: true}, &reloader)

      # non blocking listener
      listener.start
    end

    def relative_path(path)
      base_path = self.reader.mounting_point.path
      relative_path = path.sub(base_path, '')
    end

  end

end