require 'locomotive/common'

require_relative '../tools/styled_yaml'

require_relative 'loggers/pull_logger'

require_relative_all  'concerns'

require_relative      'pull_sub_commands/pull_base_command'
require_relative_all  'pull_sub_commands'

module Locomotive::Wagon

  class PullCommand < Struct.new(:env, :path, :options, :shell)

    RESOURCES = %w(site pages content_types content_entries snippets theme_assets translations content_assets).freeze

    include ApiConcern
    include DeployFileConcern
    include InstrumentationConcern
    include SpinnerConcern

    def self.pull(env, path, options, shell)
      self.new(env, path, options, shell).pull
    end

    def pull
      if options[:verbose]
        PullLogger.new
        _pull
      else
        show_wait_spinner('Pulling...') { _pull }
      end
    end

    private

    def _pull
      api_client = api_site_client(connection_information)

      site = api_client.current_site.get

      each_resource do |klass|
        klass.pull(api_client, site, path, env)
      end

      print_result_message
    end

    def each_resource
      RESOURCES.each do |name|
        next if !options[:resources].blank? && !options[:resources].include?(name)

        klass = "Locomotive::Wagon::Pull#{name.camelcase}Command".constantize

        yield klass
      end
    end

    def connection_information
      read_deploy_settings(self.env, self.path)
    end

    def print_result_message
      shell.try(:say, "\n\nThe templates, theme assets and content have been pulled from the remote version.", :green)
      true
    end

  end

end
