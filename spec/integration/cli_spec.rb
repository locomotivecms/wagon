# encoding: utf-8

require File.dirname(__FILE__) + '/integration_helper'
require 'locomotive/wagon/cli'

describe Locomotive::Wagon::CLI do

  subject { capture(:stdout) { command } }

  describe '#version' do

    let(:command) { Locomotive::Wagon::CLI::Main.start(['version']) }
    it { is_expected.to match /^3\.0/ }

  end

end
