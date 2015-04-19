module Locomotive::Wagon

  module InstrumentationConcern

    def instrument(action, payload = {})
      ActiveSupport::Notifications.instrument(instrument_scope_name(action), payload)
    end

    def instrument_scope_name(action)
      name = self.class.name[/::(\w+)Command$/, 1].underscore
      ['wagon', name, action.to_s].compact.join('.')
    end

  end

end
