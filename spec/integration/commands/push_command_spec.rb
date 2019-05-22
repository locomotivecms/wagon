# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/commands/push_command'
require 'thor'

describe Locomotive::Wagon::PushCommand do

  before { VCR.insert_cassette 'push', match_requests_on: [:uri, :method, :query, :body, :headers] }
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
        allow(command).to receive(:ask_for_performing).with('You are about to deploy a new site').and_return(true)
        allow(Netrc).to receive(:read).and_return(TEST_PLATFORM_ALT_URL => credentials)
        allow(command).to receive(:ask_for_performing).with("Warning! You're about to deploy data which will alter the content of your site.").and_return(true)
        allow(shell).to receive(:ask).with("What is the URL of your platform? (default: https://station.locomotive.works)").and_return(TEST_PLATFORM_URL)
        allow(shell).to receive(:ask).with('What is the handle of your site? (default: a random one)').and_return('wagon-test')
      end

      after { restore_deploy_file(default_site_path) }

      context 'answer yes to the deployment of the data' do

        before do
          allow(shell).to receive(:yes?).with("Are you sure you want to perform this action? (answer yes or no)").and_return(true)
        end

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

          it 'stops the deployment' do
            expect(shell).to receive(:say).with("Sorry, we were unable to find the credentials for this platform.\nPlease first login using the \"bundle exec wagon auth\"", :yellow)
            is_expected.to eq nil
          end

        end

      end

      context 'answer no to the deployment of the data' do

        before do
          allow(command).to receive(:ask_for_performing).with("Warning! You're about to deploy data which will alter the content of your site.").and_return(nil)
        end

        it "doesn't push the site" do
          resources = []
          ActiveSupport::Notifications.subscribe('wagon.push') do |name, start, finish, id, payload|
            resources << payload[:name]
          end
          is_expected.to eq nil
          expect(resources).to eq([])
        end

      end

    end

  end

end
