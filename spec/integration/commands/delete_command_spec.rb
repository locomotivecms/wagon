# encoding: utf-8
require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/commands/authenticate_command'
require 'locomotive/wagon/commands/delete_command'
require 'thor'

describe Locomotive::Wagon::DeleteCommand do

  before { VCR.insert_cassette 'delete', record: :new_episodes, match_requests_on: [:method, :uri, :body, :headers] }
  after  { VCR.eject_cassette }

  let(:env)             { 'production' }
  let(:path)            { default_site_path }
  let(:shell)           { Thor::Shell::Color.new }
  let(:options)         { { data: true, verbose: true } }
  let(:api_uri)         { 'http://www.example.com:3000' }
  let(:api_credentials) { { email: TEST_API_EMAIL, api_key: TEST_API_KEY } }
  let(:client_api)      { Locomotive::Coal::Client.new(api_uri, api_credentials, handle: 'www') }

  before do
    allow_any_instance_of(described_class).to receive(:read_deploy_settings).and_return({})
    allow_any_instance_of(described_class).to receive(:api_site_client)
      .and_return(client_api)
  end

  describe 'delete the current site' do

    let(:client_api)  { Locomotive::Coal::Client.new(api_uri, api_credentials, handle: 'short-lived') }
    let(:_client_api) { Locomotive::Coal::Client.new(api_uri, api_credentials) }

    before { allow(shell).to receive(:ask).and_return 'short-lived' }

    before { _client_api.sites.create(name: 'ShortLived', handle: 'short-lived') }

    subject { described_class.delete(env, path, 'site', nil, shell) }

    it { is_expected.to be_a(Locomotive::Coal::Resource) }

  end

  context 'resource exists' do

    let(:resource_id) { nil }

    subject { described_class.delete(env, path, resource_type, resource_id, shell) }

    describe 'delete page resource' do

      let(:resource_type) { 'page' }
      let(:resource_id)   { 'hello-world' }

      before { client_api.pages.create(title: 'Hello world', slug: 'hello-world', parent: 'index', template: 'Hello world!') }
      it { is_expected.to be_a(Locomotive::Coal::Resource) }

    end

    describe 'delete content type resource' do

      let(:resource_type) { 'content_type' }
      let(:resource_id)   { 'fake_messages' }

      before { client_api.content_types.create(name: 'FakeMessages', slug: 'fake-messages', fields: [{ label: 'E-mail', name: 'email', type: 'string' }]) }
      it { is_expected.to be_a(Locomotive::Coal::Resource) }

      describe 'all of them' do

        let(:resource_type) { 'content_types' }

        before { client_api.content_types.create(name: 'FakeMessages', slug: 'fake-messages-2', fields: [{ label: 'E-mail', name: 'email', type: 'string' }]) }
        it { expect(subject['deletions']).to be >= 1 }

      end

    end

    describe 'delete snippet resource' do

      let(:resource_type) { 'snippet' }
      let(:resource_id)   { 'analytics' }

      before { client_api.snippets.create(name: 'Analytics', slug: 'analytics', template: 'Analytics') }
      it { is_expected.to be_a(Locomotive::Coal::Resource) }

      describe 'all of them' do

        let(:resource_type) { 'snippets' }

        before { client_api.snippets.create(name: 'Analytics', slug: 'analytics_2', template: 'Analytics') }
        it { expect(subject['deletions']).to be >= 1 }

      end

    end

    describe 'delete all theme asset resources' do

      let(:resource_type) { 'theme_assets' }

      before {
        client_api.theme_assets.create(source: Locomotive::Coal::UploadIO.new(File.join(default_site_path, 'icon.png')))
        client_api.theme_assets.create(source: Locomotive::Coal::UploadIO.new(File.join(default_site_path, 'public', 'samples', 'photo.jpg')))
      }

      it { expect(subject['deletions']).to be >= 2 }

    end

    describe 'delete translation resource' do

      let(:resource_type) { 'translation' }
      let(:resource_id)   { 'hello_world' }

      before { client_api.translations.create(key: 'hello_world', values: { fr: 'Bonjour le monde' }) }
      it { is_expected.to be_a(Locomotive::Coal::Resource) }

      describe 'all of them' do

        let(:resource_type) { 'translations' }

        before { client_api.translations.create(key: 'hello_world_2', values: { fr: 'Bonjour le monde' }) }
        it { expect(subject['deletions']).to be >= 1 }

      end

    end

  end

  context 'resource does not exist' do
    describe '.delete' do
      [ ['page', 'bogus_id'],
        ['content_type', 'bogus_id'],
        ['snippet', 'bogus_id'],
        ['translation', 'bogus_id']
      ].each do |resource, id|
        describe resource do
          it 'raises an exception' do
            expect { described_class.delete(env, path, resource, id) }
              .to raise_error(Locomotive::Coal::UnknownResourceError)
          end
        end
      end
    end
  end


end
