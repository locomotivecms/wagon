module Locomotive::Wagon

  class PushBaseCommand < Struct.new(:api_client, :steam_services, :content_assets_pusher, :remote_site)

    extend Forwardable

    def_delegators :steam_services, :current_site, :locale, :repositories

    def self.push(api_client, steam_services, content_assets_pusher, remote_site)
      instance = new(api_client, steam_services, content_assets_pusher, remote_site)
      yield instance if block_given?
      instance.push
    end

    def push
      instrument do
        instrument :start
        self._push_with_timezone
        instrument :done
      end
    end

    def _push_with_timezone
      Time.use_zone(current_site.try(:timezone)) do
        _push
      end
    end

    def _push
      entities.each do |entity|
        decorated = decorate(entity)
        begin
          instrument :persist, label: label_for(decorated)
          persist(decorated)
          instrument :persist_with_success
        rescue SkipPersistingException => e
          instrument :skip_persisting
        rescue Exception => e
          instrument :persist_with_error, message: e.message
          raise e
        end
      end
    end

    def instrument(action = nil, payload = {}, &block)
      name = ['wagon.push', [*action]].flatten.compact.join('.')
      ActiveSupport::Notifications.instrument(name, { name: resource_name }.merge(payload), &block)
    end

    def resource_name
      self.class.name[/::Push(\w+)Command$/, 1].underscore
    end

    def default_locale
      current_site.default_locale
    end

    def locales
      current_site.locales
    end

    def path
      File.expand_path(repositories.adapter.options[:path])
    end

    def with_data
      @with_data = true
    end

    def with_data?
      !!@with_data
    end

    class SkipPersistingException < Exception
    end

  end

end
