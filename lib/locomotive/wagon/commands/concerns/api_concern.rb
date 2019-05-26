require 'locomotive/coal'

module Locomotive::Wagon

  module ApiConcern

    # Instance of the API client to request an account or his/her list of sites.
    def api_client
      @api_client ||= Locomotive::Coal::Client.new(api_uri, api_credentials)
    end

    # Instance of the API client to request resources of a site: pages, theme_assets, ...etc.
    def api_site_client(connection)
      return if connection.nil?
      return @api_site_client if @api_site_client

      _host, _credentials = connection['host'], connection.slice('email', 'api_key', 'password')
      _options = connection.slice('ssl', 'handle')

      @api_site_client = Locomotive::Coal::Client.new(_host, _credentials, _options)
    end

    alias :build_api_site_client :api_site_client

    # Host (+ port) extracted from the platform_url instance variable.
    # If port equals 80, do not add it to the host.
    #
    # Examples:
    #
    #     www.myengine.com
    #     localhost:3000
    #
    def api_host
      uri = api_uri
      host, port = uri.host, uri.port

      port == 80 ? uri.host : "#{uri.host}:#{uri.port}"
    end

    def api_credentials
      if respond_to?(:email)
        { email: email, password: password }
      elsif respond_to?(:credentials)
        credentials
      end
    end

    def connection_information_from_env_and_path
      read_deploy_settings(self.env, self.path)
    end

    private

    def api_uri
      if (self.platform_url =~ /^https?:\/\//).nil?
        self.platform_url = 'http://' + self.platform_url
      end

      URI(platform_url)
    end

  end

end
