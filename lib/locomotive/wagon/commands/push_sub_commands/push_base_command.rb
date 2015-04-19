module Locomotive::Wagon

  class PushBaseCommand < Struct.new(:api_client, :steam_services)

    extend Forwardable

    def_delegators :steam_services, :current_site, :locale, :repositories

    def self.push(api_client, steam_services)
      new(api_client, steam_services).push
    end

    def push
      instrument do
        instrument :start
        self._push
        instrument :done
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

    def path
      repositories.adapter.options[:path]
    end

    class SkipPersistingException < Exception
    end

  end

end
