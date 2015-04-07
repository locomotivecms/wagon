# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/commands/authenticate_command'

describe Locomotive::Wagon::AuthenticateCommand do

  let(:platform_url)  {}
  let(:email)         {}
  let(:password)      {}
  let(:shell)         { nil }
  let(:command)       { described_class.new(platform_url, email, password, shell) }

  describe '#authenticate' do

    subject { command.authenticate }

    it { is_expected.to eq(true) }

  end

end
