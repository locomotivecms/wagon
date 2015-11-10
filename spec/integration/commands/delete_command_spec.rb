# encoding: utf-8
require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/commands/authenticate_command'
require 'locomotive/wagon/commands/delete_command'
require 'thor'

describe Locomotive::Wagon::DeleteCommand do

  before { VCR.insert_cassette 'delete', record: :new_episodes, match_requests_on: [:method, :uri, :body] }
  after  { VCR.eject_cassette }

  let(:env)             { 'production' }
  let(:path)            { default_site_path }
  let(:shell)           { Thor::Shell::Color.new }
  let(:options)         { { data: true, verbose: true } }
  let(:api_uri)         { 'http://www.example.com:3000' }
  let(:api_credentials) { { email: TEST_API_EMAIL, api_key: TEST_API_KEY } }

  before do
    allow_any_instance_of(described_class).to receive(:read_deploy_settings).and_return({})
    allow_any_instance_of(described_class).to receive(:api_site_client)
      .and_return(Locomotive::Coal::Client.new(api_uri, api_credentials, handle: 'pleasant-winds-1002'))

  end

  context 'resource exists' do
    context 'by id' do
      describe '.delete' do
        [ ['page', '564141a1cde736424c00009a'],
          ['content_type', '5641419ccde736424c00000d'],
          ['snippet', '564141a3cde736424c0000b2'],
          ['theme_asset', '564141a4cde736424c0000bd'],
          ['translation', '564141a5cde736424c0000c6'],
          ['content_asset', '5641419dcde736424c000033']
        ].each do |resource, id|
          describe resource do
            subject { described_class.delete(env, path, resource, id) }
            it { is_expected.to be_a(Locomotive::Coal::Resource) }
          end
        end
      end
    end

    context 'by slug' do
      
    end
  end

  context 'resource does not exist' do
    describe '.delete' do
      [ ['page', 'bogus_id'],
        ['content_type', 'bogus_id'],
        ['snippet', 'bogus_id'],
        ['theme_asset', 'bogus_id'],
        ['translation', 'bogus_id'],
        ['content_asset', 'bogus_id']
      ].each do |resource, id|
        describe resource do
          it 'raises an exception' do
            expect{ described_class.delete(env, path, resource, id) }
              .to raise_error(Locomotive::Coal::UnknownResourceError)
          end
        end
      end
    end
  end


end
