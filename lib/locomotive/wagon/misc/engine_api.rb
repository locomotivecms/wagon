require 'httparty'

module Locomotive
  class ClientAPI

    include HTTParty

    base_uri ENV['HOSTING_URL'] || 'https://www.locomotivehosting.fr'

    def host
      URI(self.class.base_uri).host
    end

    def auth_token(email, password)
      response = self.class.get('/locomotive/api/tokens.json', { body: { email: email, password: password }})

      if response.success?
        response['token']
      end
    end

    def api_key(email, password)
      if auth_token = auth_token(email, password)
        my_account(auth_token)['api_key']
      end
    end

    def my_account(auth_token)
      self.class.get('/locomotive/api/my_account.json', { query: { auth_token: auth_token }})
    end

    def create_account(name, email, password)
      account = { name: name, email: email, password: password, password_confirmation: password }

      response = self.class.post('/locomotive/api/my_account.json', { body: { account: account }})

      if response.success?
        response.parsed_response
      end
    end

  end
end