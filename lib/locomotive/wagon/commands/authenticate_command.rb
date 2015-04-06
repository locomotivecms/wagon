module Locomotive::Wagon

  class AuthenticateCommand < Struct.new(:platform_url, :email, :password, :shell)

    def self.authenticate(platform_url, email, password, shell)
      self.new(platform_url, email, password, shell).authenticate
    end

    def authenticate
      puts "[auth] #{platform_url.inspect} / #{email.inspect} / #{password.inspect}"
      puts 'YOUPI'

      # require 'locomotive/wagon/misc/hosting_api'
      # require 'locomotive/coal'
      # require 'netrc'

      # api_key = nil
      # api     = Locomotive::HostingAPI.new(email: email, password: password)

      # if api.authenticated?
      #   # existing account
      #   api_key = api.api_key
      #   shell.say "You have been successfully authenticated.", :green
      # else
      #   # new account?
      #   shell.say "No account found for #{email} or invalid credentials", :yellow

      #   if shell.yes?('Do you want to create a new account? [Y/N]')
      #     name = shell.ask 'What is your name?'

      #     account = api.create_account(name: name, email: email, password: password)

      #     if account.success?
      #       shell.say "Your account has been successfully created.", :green
      #       api_key = account['api_key']
      #     else
      #       shell.say "We were unable to create your account, reason(s): #{account.error_messages.join(', ')}", :red
      #     end
      #   end
      # end

      # if api_key
      #   # record the credentials
      #   netrc = Netrc.read
      #   netrc[api.domain_with_port] = email, api_key
      #   netrc.save
      # else
      #   shell.say "We were unable to authenticate you on our platform.", :red
      # end
    end

    private

    def api_key_from_credentials
      # client = Locomotive::Coal::Client.new('http://www.myengine.dev/locomotive/api', { email: <EMAIL>, api_key: <API KEY> })
    end

  end

end
