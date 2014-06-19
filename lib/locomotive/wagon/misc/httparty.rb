require 'uri'

module Locomotive
  module Wagon
    module Httparty
      class Webservice

        include ::HTTParty

        def self.consume(url, options = {})
          url = ::HTTParty.normalize_base_uri(url)

          uri = URI.parse(url)
          options[:base_uri] = "#{uri.scheme}://#{uri.host}"
          options[:base_uri] += ":#{uri.port}" if uri.port != 80
          path = uri.request_uri

          options.delete(:format) if options[:format] == 'default'
          options[:format]  = options[:format].gsub(/[\'\"]/, '').to_sym if options.has_key?(:format)
          options[:headers] = { 'User-Agent' => 'LocomotiveCMS' } if options[:with_user_agent]

          username, password = options.delete(:username), options.delete(:password)
          options[:basic_auth] = { username: username, password: password } if username

          path ||= '/'

          # Locomotive::Wagon::Logger.debug "[WebService] consuming #{path}, #{options.inspect}"

          response = self.get(path, options)

          if response.code == 200
            _response = response.parsed_response
            if _response.respond_to?(:underscore_keys)
              _response.underscore_keys
            else
              _response.collect(&:underscore_keys)
            end
          else
            Locomotive::Wagon::Logger.error "[WebService] consumed #{path}, #{options.inspect}, response = #{response.inspect}"
            nil
          end

        end

      end
    end
  end
end