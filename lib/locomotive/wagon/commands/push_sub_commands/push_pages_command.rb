module Locomotive::Wagon

  class PushPagesCommand < PushBaseCommand

    # TODO:
    # - get the id if it exists (fullpath in the default locale)
    # - content asset pusher
    # - do not send editable elements without the -d option
    # x i18ndecorator for editable_elements
    # - persist
    # - load remote entities (modify both coal + engine to pass the locale)

    def entities
      binding.pry
      repositories.page.all
    end

    def decorate(entity)
      PageDecorator.new(entity, locale)
    end

    def persist(decorated_entity)
      translated_in(decorated_entity) do |locale|
        puts locale.to_s + ' - ' + decorated_entity.to_hash.inspect
      end

      # puts decorated_entity.to_hash
      # api_client.snippets.update(decorated_entity.slug, decorated_entity.to_hash)
    end

    def label_for(decorated_entity)
      _locales = translated_in(decorated_entity).join(', ')

      if _locales.blank?
        decorated_entity.fullpath
      else
        decorated_entity.fullpath + " (#{_locales})"
      end
    end

    private

    def remote_entities
      return @remote_entities if @remote_entities

      @remote_entities = {}.tap do |hash|
        api_client.pages.all.each do |entity|
          hash[entity.fullpath] = entity
        end
      end
    end

    def translated_in(decorated_entity, &block)
      locales.find_all do |locale|
        decorated_entity.__with_locale__(locale) do
          decorated_entity.slug.present?.tap do |present|
            yield(locale) if block_given? && present
          end
        end
      end
    end

  end

end
