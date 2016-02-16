module Locomotive
  module Wagon

    class SnippetDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern
      include PersistAssetsConcern

      attr_accessor :__content_assets_pusher__

      def initialize(object, locale = nil, content_assets_pusher)
        self.__content_assets_pusher__ = content_assets_pusher
        super(object, locale, nil)
      end

      def __attributes__
        %i(name slug template)
      end

      def id
        slug
      end

      def template
        {}.tap do |translations|
          __getobj__.template_path.translations.each do |locale, _|
            __with_locale__(locale) do
              translations[locale] = replace_with_content_assets!(self.liquid_source)
            end
          end
        end
      end

    end

  end
end
