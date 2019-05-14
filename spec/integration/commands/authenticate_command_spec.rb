# # encoding: utf-8

# require File.dirname(__FILE__) + '/../integration_helper'
# require 'locomotive/wagon/commands/authenticate_command'
# require 'thor'

# describe Locomotive::Wagon::AuthenticateCommand do

#   before { VCR.insert_cassette 'authenticate', record: :new_episodes, match_requests_on: [:method, :query, :body] }
#   after  { VCR.eject_cassette }

#   let(:platform_url)  { TEST_PLATFORM_URL }
#   let(:shell)         { Thor::Shell::Color.new }
#   let(:command)       { described_class.new(platform_url, email, password, shell) }

#   describe '#authenticate' do

#     let(:netrc) { instance_double('netrc', save: true) }

#     before { allow(Netrc).to receive(:read).and_return(netrc) }

#     subject { command.authenticate }

#     context 'new account' do

#       let(:email)     { 'john@doe.net' }
#       let(:password)  { 'asimplepassword' }

#       before do
#         allow_any_instance_of(Locomotive::Coal::Resource).to receive(:api_key).and_return('42')
#         allow(Thor::LineEditor).to receive(:readline).and_return('Y', 'John')
#       end

#       it 'creates a new account and puts the auto-login information in the .netrc file' do
#         expect(netrc).to receive(:[]=).with('localhost:3000', ['john@doe.net', '42'])
#         is_expected.to eq(true)
#       end

#     end

#     context 'existing account' do

#       let(:email)     { TEST_API_EMAIL }
#       let(:password)  { TEST_API_PASSWORD }
#       let(:netrc)     { instance_double('netrc', save: true) }

#       before do
#         allow_any_instance_of(Locomotive::Coal::Resource).to receive(:api_key).and_return('42')
#       end

#       it 'only puts the auto-login information in the .netrc file' do
#         expect(netrc).to receive(:[]=).with('localhost:3000', ['admin@locomotivecms.com', '42'])
#         is_expected.to eq(true)
#       end

#     end

#   end

# end
