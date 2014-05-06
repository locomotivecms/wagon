require 'locomotive/wagon/misc/hosting_api'
require 'active_support/core_ext/hash'
require 'netrc'
require 'erb'

module Locomotive
  module Wagon

    class DeploymentConnection

      # Create a connection for the deployment
      # from the path of a Wagon site.
      #
      # @param [ String ] path Path to a Wagon site
      #
      def initialize(path, shell = nil)
        @path   = path
        @shell  = shell
      end

      # Retrieve information connection from the
      # config/deploy.yml file and for a specific environment.
      # If the env is hosting and does not have an entry in that file,
      # then it looks for an api key in the ~/.netrc file, assuming
      # that the user authenticates himself previously thanks to the
      # auth wagon command.
      #
      # @param [ String ] env The target environment to deploy the site.
      #
      def get_information(env)
        connection_info = read_from_yaml_file(env)

        # is the user owns a hosting account, then use his credentials
        # to create a new site.
        if connection_info.nil? && env == 'hosting'
          connection_info = read_from_hosting
        end

        if connection_info.nil?
          raise "No #{env.to_s} environment found in the config/deploy.yml file"
        end

        connection_info = connection_info.with_indifferent_access

        if connection_info[:ssl] && !connection_info[:host].start_with?('https')
          connection_info[:host] = 'https://' + connection_info[:host]
        end

        connection_info
      end

      private

      def deploy_file
        File.join(@path, 'config', 'deploy.yml')
      end

      def read_from_yaml_file(env)
        # pre-processing: erb code to parse and render?
        parsed_deploy_file = ERB.new(File.open(deploy_file).read).result

        # finally, get the hash from the YAML file
        environments = YAML::load(parsed_deploy_file)
        (environments.is_a?(Hash) ? environments : {})[env.to_s]
      rescue Exception => e
        raise "Unable to read the config/deploy.yml file (#{e.message})"
      end

      def read_from_hosting
        hosting_api = new_hosting_api

        # create the site (READ the site.yml file to get the information)
        site = hosting_api.create_site(site_attributes)

        if site.success?
          # now we've got the subdomain, build the target host
          host = [site['subdomain'], hosting_api.domain_with_port].join('.')

          # return the connection information
          { 'host' => host, 'api_key' => hosting_api.api_key }.tap do |hash|
            # add ssl only if it is asked
            hash['ssl'] if hosting_api.ssl?

            # insert a new entry for hosting env in the current deploy.yml
            File.open(deploy_file, 'a+') do |f|
              f.write({ 'hosting' => hash }.to_yaml.sub(/^---/, ''))
            end
          end
        else
          raise "We were unable to create a new site on the hosting, reason(s): #{site.error_messages.join(', ')}"
        end
      end

      def new_hosting_api
        Locomotive::HostingAPI.new.tap do |hosting_api|
          netrc = Netrc.read
          email, api_key = netrc[hosting_api.domain_with_port]

          # get a new auth token for further API calls
          hosting_api.authenticate(api_key: api_key)
        end
      end

      def config_file
        File.join(@path, 'config', 'site.yml')
      end

      def site_attributes
        YAML::load(File.read(config_file)).tap do |attributes|
          # ask for the subdomain
          if attributes['subdomain'].blank? && @shell
            attributes['subdomain'] = @shell.ask("Please, what's your subdomain? (leave it blank for a random one)")
          end
        end
      end

    end

  end
end