module Locomotive::Wagon

  class SyncBaseCommand < Locomotive::Wagon::PullBaseCommand

    def self.sync(api_client, current_site, path)
      new(api_client, current_site, path).sync
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
