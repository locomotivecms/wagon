require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/cli'


describe Locomotive::Wagon::CLI::Generate do
  let(:path) { File.join(File.dirname(__FILE__), '../../fixtures', 'default') }
  before { Locomotive::Wagon::CLI::Generate.options[:path] = path }

  describe '#generate' do
    subject { capture(:stdout) { Locomotive::Wagon::CLI::Generate.new([], path: path).invoke(:content_type, ['post', *fields]) } }

    describe '#content_type' do
      context 'no fields provided' do
        let(:fields) { nil }
        it 'displays and error and doesnt generate' do
          should match 'The fields are missing'
          Locomotive::Wagon.should_not_receive :generate
        end
      end

      context 'with fields provided' do
        let(:fields) { ['title', 'content'] }
        it 'displays and error and doesnt generate' do
          Locomotive::Wagon.should_receive(:generate).and_return
          subject
        end
      end
    end
  end
end