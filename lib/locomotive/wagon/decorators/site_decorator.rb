module Locomotive
  module Wagon

    class SiteDecorator < SimpleDelegator

      include ToHashConcern

      def domains
        (__getobj__.domains || []) - ['localhost']
      end

      def picture
        picture_path = __getobj__.picture
        if picture_path && File.exists?(picture_path)
          Locomotive::Coal::UploadIO.new(picture_path, nil, 'icon.png')
        else
          nil
        end
      end

      %i(robots_txt timezone seo_title meta_keywords meta_description).each do |name|
        define_method(name) do
          self[name]
        end
      end

      def __attributes__
        %i(name handle robots_txt locales timezone seo_title meta_keywords meta_description picture)
      end

      def edited?
        (self[:content_version].try(:to_i) || 0) > 0
      end

    end

    class UpdateSiteDecorator < SiteDecorator

      def __attributes__
        %i(picture locales)
      end

    end

  end
end
