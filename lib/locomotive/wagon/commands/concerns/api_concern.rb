require 'locomotive/coal'

module Locomotive::Wagon

  module ApiConcern

    private

    def api_client
      @api_client ||= Locomotive::Coal::Client.new(api_url, api_credentials)
    end

    def api_credentials
      if respond_to?(:email)
        { email: email, password: password }
      elsif respond_to?(:credentials)
        credentials
      end
    end

    def api_url
      uri = URI(platform_url)
      uri.merge!('/locomotive/api/v3') if uri.path == '/' || uri.path == ''
      uri.to_s
    end

  end

end
