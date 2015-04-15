module Locomotive::Wagon

  class PushBaseCommand < Struct.new(:api_client, :steam_services)

    extend Forwardable

    def_delegators :steam_services, :current_site, :locale, :repositories

    def default_locale
      current_site.default_locale
    end

  end

end
