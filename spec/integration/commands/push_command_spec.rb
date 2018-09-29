# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/commands/push_command'
require 'thor'

describe Locomotive::Wagon::PushCommand do

  before { VCR.insert_cassette 'push', match_requests_on: [:uri, :method, :query, :body] }
  after  { VCR.eject_cassette }

  let(:env)       { 'production' }
  let(:path)      { default_site_path }
  let(:shell)     { Thor::Shell::Color.new }
  let(:options)   { { data: true, verbose: true } }
  let(:command)   { described_class.new(env, path, options, shell) }

  describe '#push' do

    subject { command.push }

    context 'unknown env' do

      let(:credentials) { instance_double('Credentials', login: TEST_API_EMAIL, password: TEST_API_KEY) }
      let(:env) { 'hosting' }

      before do
        allow(Netrc).to receive(:read).and_return(TEST_PLATFORM_ALT_URL => credentials)
        allow(shell).to receive(:ask).with("What is the URL of your platform? (default: http://locomotive.works)").and_return(TEST_PLATFORM_URL)
        allow(shell).to receive(:ask).with('What is the handle of your site? (default: a random one)').and_return('wagon-test')
      end

      after { restore_deploy_file(default_site_path) }

      it 'creates a site and push the site' do
        resources = []
        ActiveSupport::Notifications.subscribe('wagon.push') do |name, start, finish, id, payload|
          resources << payload[:name]
        end
        is_expected.not_to eq nil
        expect(resources).to eq %w(site content_types content_entries pages snippets sections theme_assets translations)
      end

      context 'no previous authentication' do

        let(:credentials) { nil }

        it { expect { subject }.to raise_error('You need to run wagon authenticate before going further') }

      end

    end

  end

end
