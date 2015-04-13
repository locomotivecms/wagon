require 'netrc'

module Locomotive::Wagon

  module NetrcConcern

    def write_credentials_to_netrc(host, email, api_key)
      netrc = Netrc.read
      netrc[host] = email, api_key
      netrc.save
    end

    def read_credentials_from_netrc(host)
      if entry = Netrc.read[host]
        { email: entry.login, api_key: entry.password }
      end
    end

  end

end
