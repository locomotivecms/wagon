# require_relative 'initializers/*'

Locomotive::Common.configure do |config|
  config.notifier = Locomotive::Common::Logger.setup
end
