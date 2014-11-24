require 'httparty'

module Locomotive
  class HostingAPI

    include HTTParty

    base_uri ENV['HOSTING_URL'] || 'http://www.locomotivehosting.com'
    # base_uri ENV['HOSTING_URL'] || 'http://www.locomotivehosting.fr'
    # base_uri ENV['HOSTING_URL'] || 'http://www.locomotivehosting.dev:3000'

    def initialize(credentials = nil)
      authenticate(credentials) if credentials
    end

    def self.host
      URI(base_uri).host
    end

    def base_uri; self.class.base_uri; end
    def host; self.class.host; end
    def port; URI(self.class.base_uri).port; end

    def domain
      host.split('.')[1..-1].join('.') # TLD length of 2
    end

    def domain_with_port
      if port != 80
        self.domain + ":#{port}"
      else
        self.domain
      end
    end

    def ssl?
      URI(self.class.base_uri).scheme == 'https'
    end

    def authenticate(credentials)
      response = self.class.post('/locomotive/api/tokens.json', { body: credentials })

      if response.success?
        @auth_token = response['token']
      end
    end

    def authenticated?
      !!@auth_token
    end

    def api_key
      @api_key ||= api_key!
    end

    def api_key!
      return false unless authenticated?

      my_account['api_key']
    end

    def my_account
      self.class.get('/locomotive/api/my_account.json', { query: { auth_token: @auth_token }})
    end

    def create_account(attributes)
      attributes[:password_confirmation] = attributes[:password]

      _response = self.class.post('/locomotive/api/my_account.json', { body: { account: attributes }})

      Response.new(_response.parsed_response).tap do |response|
        response.success = _response.success?
      end
    end

    def create_site(attributes)
      _response = self.class.post('/locomotive/api/sites.json', { body: { auth_token: @auth_token, site: attributes }})

      Response.new(_response.parsed_response).tap do |response|
        response.success = _response.success?
      end
    end

    class Response < Hash

      attr_writer :success

      def initialize(attributes = {})
        replace(attributes)
      end

      def success?
        !!@success
      end

      def errors
        return nil if success?

        @errors ||= if self['error']
          [[nil, [self['error']]]]
        elsif self['errors']
          self['errors']
        else
          self.to_a
        end.delete_if { |attribute, errors| errors.empty? }
      end

      def error_messages
        return nil if success? || errors.nil?

        errors.to_a.map { |attribute, messages| messages.map { |message| [attribute, message].compact.join(' ') } }.flatten
      end

    end

  end
end
