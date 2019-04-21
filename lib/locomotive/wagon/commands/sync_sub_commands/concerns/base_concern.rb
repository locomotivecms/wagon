require 'active_support/concern'

module Locomotive::Wagon

  module BaseConcern

    extend ActiveSupport::Concern

    included do

      alias :_sync :_pull

    end

    module ClassMethods

      def sync(api_client, current_site, path, env)
        new(api_client, current_site, path, env).sync
      end

    end

    def sync
      instrument do
        instrument :start
        self._sync
        instrument :done
      end
    end

    def instrument_base_name
      'wagon.sync'
    end

    def resource_name
      self.class.name[/::Sync(\w+)Command$/, 1].underscore
    end

  end

end
