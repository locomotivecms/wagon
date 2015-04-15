module Locomotive::Wagon

  class PushSnippetsCommand < PushBaseCommand

    def self.push(api_client, steam_services)
      new(api_client, steam_services).push
    end

    def push
      ActiveSupport::Notifications.instrument('wagon.push', resource: :snippets) do
        entities.each do |entity|
          decorated = SnippetDecorator.new(entity, locale, default_locale)
          api_client.snippets.update(decorated.slug, decorated.to_hash)
        end
      end
    end

    private

    def entities
      repositories.snippet.all
    end

  end

end
