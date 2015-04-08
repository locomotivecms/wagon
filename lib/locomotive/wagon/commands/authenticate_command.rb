require 'locomotive/coal'
require 'netrc'

module Locomotive::Wagon

  class AuthenticateCommand < Struct.new(:platform_url, :email, :password, :shell)

    def self.authenticate(platform_url, email, password, shell)
      self.new(platform_url, email, password, shell).authenticate
    end

    def authenticate
      if api_key = fetch_api_key
        record_credentials(api_key)
      else
        shell.say "Sorry, we were unable to authenticate you on \"#{platform_url}\"", :red
      end

      !api_key.nil?
    end

    def fetch_api_key
      if my_account
        my_account.api_key
      else
        shell.say "No account found for #{email} or invalid credentials", :yellow

        # shall we create a new account?
        if shell.yes?('Do you want to create a new account? [Y/N]')
          create_account
        else
          false
        end
      end
    end

    def create_account
      name = shell.ask 'What is your name?'

      begin
        account = client.my_account.create(name: name, email: email, password: password)
        shell.say "Your account has been successfully created.", :green
        account.api_key
      rescue Locomotive::Coal::Error => e
        shell.say "We were unable to create your account, reason(s): #{e.message}", :red
        false
      end
    end

    def record_credentials(api_key)
      uri = URI(platform_url)
      key = "#{uri.host}:#{uri.port}"

      netrc = Netrc.read
      netrc[key] = email, api_key
      netrc.save
    end

    private

    def my_account
      begin
        client.my_account.get
      rescue Locomotive::Coal::UnauthorizedError
        nil
      end
    end

    def client
      @client ||= Locomotive::Coal::Client.new(api_url, email: email, password: password)
    end

    def api_url
      uri = URI(platform_url)
      uri.merge!('/locomotive/api/v3') if uri.path == '/' || uri.path == ''
      uri.to_s
    end

  end

end
