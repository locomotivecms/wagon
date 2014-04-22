require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/cli'

describe Locomotive::Wagon::CLI::Main do
  describe '#serve' do
    let(:output) { capture(:stdout) { subject.serve path }}

    context 'when no site in path' do
      let(:path) { 'a/path/with/no/site' }
      it 'outputs an explicit error' do
        output.should match 'The path does not point to a LocomotiveCMS site'
      end
      it 'Does not serve' do
        Locomotive::Wagon.should_not_receive(:serve)
        quietly { subject.serve path } # active_support / core_ext / kernel / reporting.rb
      end
    end
    context 'when site in path' do
      let(:path) { File.join(File.dirname(__FILE__), '../../fixtures', 'default') }
      it 'Uses Wagon#serve' do
        Locomotive::Wagon.should_receive(:serve)
        subject.serve path
      end
      it 'outputs positive message' do
        Locomotive::Wagon.stub(:serve).and_raise SystemExit
        output.should match 'Your site is served now.'
      end
    end
  end

end
