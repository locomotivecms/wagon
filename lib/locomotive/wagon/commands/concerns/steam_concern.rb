require 'locomotive/coal'

module Locomotive::Wagon

  module SteamConcern

    def steam_services
      return @steam_services if @steam_services

      Locomotive::Steam.configure do |config|
        config.mode           = :test
        config.adapter        = { name: :filesystem, path: path, env: options[:env]&.to_sym || :local }
        config.asset_path     = File.expand_path(File.join(path, 'public'))
        config.minify_assets  = false
      end

      @steam_services = Locomotive::Steam::Services.build_instance.tap do |services|
        repositories = services.repositories
        services.set_site(repositories.site.all.first)
        services.locale = services.current_site.default_locale
      end
    end

  end
end
