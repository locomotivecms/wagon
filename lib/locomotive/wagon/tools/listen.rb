require 'listen'

module Locomotive::Wagon

  class Listen < Struct.new(:path, :cache)

    def self.start(path, cache)
      new(path, cache).tap { |instance| instance.apply_definitions }
    end

    def apply_definitions
      self.definitions.each do |definition|
        self.apply(definition)
      end
    end

    protected

    def definitions
      [
        ['config', /\.yml/, [:site, :content_types, :pages, :snippets, :sections, :content_entries, :translations]],
        ['app/views', %r{(pages|snippets|sections)/(.+\.liquid).*}, [:pages, :snippets, :sections]],
        ['app/content_types', /\.yml/, [:content_types, :content_entries]],
        ['data', /\.yml/, :content_entries],
        ['public', %r{((stylesheets|javascripts)/(.+\.(css|js))).*}, []]
      ]
    end

    def apply(definition)
      reloader  = build_reloader([*definition.last])
      filter    = definition[1]
      _path     = File.expand_path(File.join(self.path, definition.first))

      listener = ::Listen.to(_path, only: filter, &reloader)

      # non blocking listener
      listener.start
    end

    def build_reloader(resources)
      Proc.new do |modified, added, removed|
        resources.each do |resource|
          Locomotive::Common::Logger.info "service=listen action=reload resource=#{resource} timestamp=#{Time.now}"

          clear_cache_for(resource, modified + added + removed)
        end
      end
    end

    def clear_cache_for(resource, files)
      keys = case resource
      when :site  then '_sites'
      when :content_entries
        files.map { |f| "site_1_content_type_#{File.basename(f, '.yml')}_content_entries" }
      else
        "site_1_#{resource}"
      end

      [*keys].each { |key| cache.delete(key) }
    end

  end

end
