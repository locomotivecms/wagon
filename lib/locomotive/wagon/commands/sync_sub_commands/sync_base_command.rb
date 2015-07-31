require_relative 'concerns/base_concern'

module Locomotive::Wagon

  class SyncBaseCommand < Locomotive::Wagon::PullBaseCommand

    include BaseConcern

  end

end
