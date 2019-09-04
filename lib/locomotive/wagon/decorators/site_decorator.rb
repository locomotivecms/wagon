module Locomotive
  module Wagon

    class SiteDecorator < Locomotive::Steam::Decorators::I18nDecorator

      include ToHashConcern
      include PersistAssetsConcern

      attr_accessor :__base_path__, :__content_assets_pusher__

      def initialize(object, locale = nil, base_path = nil, content_assets_pusher = nil)
        self.__base_path__ = base_path
        self.__content_assets_pusher__ = content_assets_pusher
        super(object, locale || object.default_locale, nil)
      end

      def domains
        (__getobj__.domains || []) - ['localhost']
      end

      def metafields_ui
        self[:metafields_ui].try(:to_json)
      end

      def metafields_schema
        self[:metafields_schema].try(:to_json)
      end

      def metafields
        replace_with_content_assets_in_hash!(self[:metafields])
        self[:metafields]&.to_json
      end

      def sections_content
        replace_with_content_assets!(super&.to_json)
      end

      def routes
        self[:routes]&.to_json
      end

      def picture
        picture_path = __getobj__.picture
        if picture_path && File.exists?(picture_path)
          Locomotive::Coal::UploadIO.new(picture_path, nil, 'icon.png')
        else
          nil
        end
      end

      %i(robots_txt timezone seo_title meta_keywords meta_description asset_host routes).each do |name|
        define_method(name) do
          self[name]
        end
      end

      def __attributes__
        %i(name handle robots_txt locales timezone seo_title meta_keywords meta_description picture metafields_schema metafields metafields_ui asset_host sections_content routes)
      end

    end

    class RemoteSiteDecorator < SimpleDelegator

      def edited?
        (self[:content_version].try(:to_i) || 0) > 0
      end

    end

    class UpdateSiteDecorator < SiteDecorator

      def __attributes__
        %i(picture timezone locales metafields_schema metafields metafields_ui asset_host sections_content routes)
      end

    end

  end
end
