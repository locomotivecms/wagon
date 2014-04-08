require_relative 'generators_helper'
require 'locomotive/wagon/generators/site'

describe Locomotive::Wagon::Generators::Site do

  class DummySite; end
  let(:generator) { Locomotive::Wagon::Generators::Site }
  let(:args) { ['my_site', DummySite, 'Dummy site generator' ] }

  describe '#register' do
    before { generator::List.instance._list = []  }
    subject { generator.register(*args) }

    context 'first time registring' do
      it { should be_true }
      it 'adds a site to the list' do
        expect { subject }.to change(generator.list, :size).by(1)
      end
    end

    context 'second time registring' do
      before { generator.register(*args) }
      it { should be_false }
      it 'adds a site to the list' do
        expect{subject}.to change(generator.list, :size).by(0)
      end
    end
  end

  describe '#get' do
    before { generator.register(*args) }

    context 'existing site skeleton' do
      subject { generator.get('my_site') }
      its(:klass) { should == DummySite }
      its(:name) { should == :my_site }
      its(:description) { should eq 'Dummy site generator' }
    end
  end

  describe '#list_to_json' do
    before do
      generator::List.instance._list = []
      generator.register('blank', Locomotive::Wagon::Generators::Site::Blank, 'Blank site')
    end

    subject { generator.list_to_json }
    it 'returns json with array of hashes' do
      JSON.parse(subject).first.should be_kind_of Hash
    end
  end
end