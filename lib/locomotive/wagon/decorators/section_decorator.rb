module Locomotive
  module Wagon

    class SectionDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern
      include PersistAssetsConcern

      attr_accessor :__content_assets_pusher__

      def initialize(object, content_assets_pusher)
        self.__content_assets_pusher__ = content_assets_pusher
        super(object, nil, nil)
      end

      def __attributes__
        %i(name slug template definition)
      end

      def id
        slug
      end

      def template
        replace_with_content_assets!(self.liquid_source)
      end

      def definition
        replace_with_content_assets!(__getobj__.definition.to_json)
      end

    end

  end
end
