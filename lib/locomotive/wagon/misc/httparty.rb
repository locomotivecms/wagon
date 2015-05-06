require 'uri'

module Locomotive
  module Wagon
    module Httparty
      class Webservice

        include ::HTTParty

        def self.consume(url, options = {})
          method = options.delete(:method).try(:to_sym) || :get

          url = ::HTTParty.normalize_base_uri(url)

          uri = URI.parse(url)
          path = uri.path.blank? ? '/' : uri.path

          if uri.query
            params = Rack::Utils.parse_nested_query(uri.query)
            key = method == :post ? :body : :query
            options[key] = params unless params.blank?
          end

          uri.query = nil; uri.path = ''
          options[:base_uri] = uri.to_s

          options.delete(:format) if options[:format] == 'default'
          options[:format]  = options[:format].gsub(/[\'\"]/, '').to_sym if options.has_key?(:format)
          options[:headers] = { 'User-Agent' => 'LocomotiveCMS' } if options[:with_user_agent]

          username, password = options.delete(:username), options.delete(:password)
          options[:basic_auth] = { username: username, password: password } if username

          Locomotive::Wagon::Logger.debug "[WebService] consuming #{path}, #{options.inspect}"

          response = self.send(method, path, options)

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
