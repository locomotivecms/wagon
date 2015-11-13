require_relative 'concerns/api_concern'
require_relative 'concerns/netrc_concern'

module Locomotive::Wagon

  class AuthenticateCommand < Struct.new(:platform_url, :email, :password, :shell)

    include ApiConcern
    include NetrcConcern

    def self.authenticate(platform_url, email, password, shell)
      self.new(platform_url, email, password, shell).authenticate
    end

    def authenticate
      if api_key = fetch_api_key
        write_credentials_to_netrc(api_host, email, api_key)
      else
        shell.say "Sorry, we were unable to authenticate you on \"#{platform_url}\"", :red
      end

      !api_key.nil?
    end

    def fetch_api_key
      if my_account
        shell.say "\nYou have been successfully authenticated.", :green
        my_account.api_key
      else
        shell.say "\nNo account found for #{email} or invalid credentials", :yellow

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
        account = api_client.my_account.create(name: name, email: email, password: password)
        shell.say "Your account has been successfully created.", :green
        account.api_key
      rescue Locomotive::Coal::Error => e
        shell.say "We were unable to create your account, reason(s): #{e.message}", :red
        false
      end
    end

    private

    def my_account
      begin
        api_client.my_account.get
      rescue Locomotive::Coal::UnauthorizedError
        nil
      end
    end

  end

end
