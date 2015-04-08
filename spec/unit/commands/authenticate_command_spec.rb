# encoding: utf-8

require 'spec_helper'
require 'locomotive/wagon/commands/authenticate_command'

describe Locomotive::Wagon::AuthenticateCommand do

  let(:platform_url)  { nil }
  let(:email)         { nil }
  let(:password)      { nil }
  let(:shell)         { nil }
  let(:command)       { described_class.new(platform_url, email, password, shell) }

  describe '#api_url' do

    subject { command.send(:api_url) }

    context 'naked domain' do
      let(:platform_url)  { 'http://www.myengine.com:3000/' }
      it { is_expected.to eq('http://www.myengine.com:3000/locomotive/api/v3') }
    end

    context 'localhost' do
      let(:platform_url)  { 'http://localhost:3000' }
      it { is_expected.to eq('http://localhost:3000/locomotive/api/v3') }
    end

    context 'including the official route to the API' do

      let(:platform_url)  { 'http://www.myengine.com:3000/locomotive/api/v3' }
      it { is_expected.to eq('http://www.myengine.com:3000/locomotive/api') }

    end

    context 'including another route to the API' do

      let(:platform_url)  { 'http://www.myengine.com/admin/api' }
      it { is_expected.to eq('http://www.myengine.com/admin/api') }

    end

  end

end
