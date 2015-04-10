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

      let(:credentials) { instance_double('Credentials', email: TEST_API_EMAIL, api_key: TEST_API_KEY) }
      let(:env) { 'hosting' }

      before do
        allow(Netrc).to receive(:read).and_return(TEST_PLATFORM_ALT_URL => credentials)
        allow(Thor::LineEditor).to receive(:readline).and_return(TEST_PLATFORM_URL.dup)
      end

      it { is_expected.to eq true }

      context 'no previous authentication' do

        let(:credentials) { nil }

        it { expect { subject }.to raise_error('You need to run wagon authenticate before going further') }

      end

    end

  end

end
