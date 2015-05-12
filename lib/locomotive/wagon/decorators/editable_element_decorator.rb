module Locomotive
  module Wagon

    class EditableElementDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern
      include PersistAssetsConcern

      attr_accessor :__content_assets_pusher__

      def initialize(object, locale = nil, content_assets_pusher)
        self.__content_assets_pusher__ = content_assets_pusher
        super(object, locale, nil)
      end

      def __attributes__
        %i(block slug content)
      end

      def content
        case value = super
        when %r(^/samples/)
          asset_io(value)
        else
          replace_with_content_assets!(value)
        end
      end

    end

  end
end
