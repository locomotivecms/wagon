# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/steam'
require 'locomotive/steam/adapters/filesystem'
require 'locomotive/wagon/commands/push_command'
require 'locomotive/wagon/commands/sync_command'
require 'thor'

describe Locomotive::Wagon::SyncCommand do

  before { Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new.clear }

  before { VCR.insert_cassette 'sync', match_requests_on: [:uri, :method, :query, :body, :headers] }
  after  { VCR.eject_cassette }

  let(:env)       { 'hosting-sync' }
  let(:path)      { default_site_path }
  let(:shell)     { Thor::Shell::Color.new }
  let(:options)   { { verbose: true } }
  let(:command)   { described_class.new(env, path, options, shell) }

  describe '#sync' do

    before  { create_site }
    after do
      restore_deploy_file(default_site_path)
      FileUtils.rm_rf(File.join(data_path))
      FileUtils.rm_rf(File.join(assets_path))
    end

    let(:data_path)     { File.join(default_site_path, 'data', 'hosting-sync') }
    let(:assets_path)   { File.join(default_site_path, 'public', 'samples', '_hosting-sync') }

    subject { command.sync }

    it 'exports the content of a site, content entries and pages' do
      is_expected.not_to eq nil
      expect(File.exists?(File.join(data_path, 'site.json'))).to eq true
      expect(File.exists?(File.join(data_path, 'content_entries', 'bands.yml'))).to eq true
      %w(fr nb en).each do |locale|
        expect(File.exists?(File.join(data_path, 'pages', locale, 'index.json'))).to eq true
      end
    end

  end

  def create_site
    _command    = Locomotive::Wagon::PushCommand.new(env, path, { data: true, verbose: false }, shell)
    credentials = instance_double('Credentials', login: TEST_API_EMAIL, password: TEST_API_KEY)
    allow(Netrc).to receive(:read).and_return(TEST_PLATFORM_ALT_URL => credentials)
    allow(_command).to receive(:ask_for_performing).with('You are about to deploy a new site').and_return(true)
    allow(_command).to receive(:ask_for_performing).with("Warning! You're about to deploy data which will alter the content of your site.").and_return(true)
    expect(shell).to receive(:ask).with("What is the URL of your platform? (default: https://station.locomotive.works)").and_return(TEST_PLATFORM_URL)
    expect(shell).to receive(:ask).with('What is the handle of your site? (default: a random one)').and_return('wagon-test-sync')
    _command.push
    # Locomotive::Wagon::PushCommand.push(env, path, { data: true, verbose: false }, shell)
  end

end
