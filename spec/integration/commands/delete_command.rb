# encoding: utf-8
require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/commands/delete_command'
require 'thor'

describe Locomotive::Wagon::DeleteCommand do

  before { VCR.insert_cassette 'delete', record: :new_episodes, match_requests_on: [:method, :query, :body] }
  after  { VCR.eject_cassette }

  let(:env)             { 'production' }
  let(:path)            { default_site_path }
  let(:shell)           { Thor::Shell::Color.new }
  let(:options)         { { data: true, verbose: true } }
  #let(:command)         { described_class.new(env, path, options, shell) }
  let(:api_uri)         { 'http://localhost:3000' }
  let(:api_credentials) { { email: TEST_API_EMAIL, api_key: TEST_API_KEY } }

  before do
    allow_any_instance_of(described_class).to receive(:read_deploy_settings).and_return({})
    allow_any_instance_of(described_class).to receive(:api_site_client)
      .and_return(Locomotive::Coal::Client.new(api_uri, api_credentials))
    allow_any_instance_of(Locomotive::Coal::Resource).to receive(:api_key).and_return('42')
  end

  describe '.delete' do
    subject { described_class.delete(env, path, 'theme_asset', '562d977dcde73600f1000000') }
    it { is_expected.to be_a(described_class) }
  end

  describe '#delete' do

  end
end
