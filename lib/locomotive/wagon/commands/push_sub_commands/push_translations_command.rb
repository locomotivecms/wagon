module Locomotive::Wagon

  class PushTranslationsCommand < PushBaseCommand

    def self.push(api_client, steam_services)
      new(api_client, steam_services).push
    end

    def push
      ActiveSupport::Notifications.instrument('wagon.push', resource: :translations) do
        entities.each do |entity|
          decorated = TranslationDecorator.new(entity)
          api_client.translations.update(decorated.id, decorated.to_hash)
        end
      end
    end

    private

    def entities
      repositories.translation.all
    end

  end

end
