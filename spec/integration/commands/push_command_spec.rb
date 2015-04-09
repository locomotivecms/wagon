# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/commands/push_command'
require 'thor'

describe Locomotive::Wagon::PushCommand do

  # before { VCR.insert_cassette 'push', record: :new_episodes, match_requests_on: [:method, :query, :body] }
  # after  { VCR.eject_cassette }

  # let(:platform_url)  { TEST_PLATFORM_URL }
  let(:env)       { 'production' }
  let(:path)      { default_site_path }
  let(:shell)     { Thor::Shell::Color.new }
  let(:options)   { { shell: shell } }
  let(:command)   { described_class.new(env, path, options) }

  describe '#push' do

    subject { command.push }

    context 'unknown env' do

      let(:env) { 'hosting' }

      it { is_expected.to eq true }

    end

  end

end
