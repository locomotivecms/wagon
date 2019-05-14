# encoding: utf-8

require 'spec_helper'

require 'locomotive/steam'
require 'locomotive/wagon/decorators/concerns/to_hash_concern'
require 'locomotive/wagon/decorators/concerns/persist_assets_concern'
require 'locomotive/wagon/decorators/content_entry_decorator'

describe Locomotive::Wagon::ContentEntryDecorator do

  let(:content_type)  { instance_double('ContentType', fields: fields) }
  let(:entry)         { instance_double('ContentEntry', attributes.merge(content_type: content_type, localized_attributes: [])) }
  let(:decorator)     { described_class.new(entry, 'en', '.') }

  before { Chronic.time_class = Time.zone }

  before { allow(decorator).to receive(:_slug).and_return('sample') }

  describe '#to_hash' do

    describe 'no field' do

      let(:fields)      { instance_double('Fields', by_name: nil, no_associations: []) }
      let(:attributes)  { {} }

      subject { decorator.to_hash }

      it { is_expected.to eq({}) }

    end

    describe 'string field' do

      let(:field)       { instance_double('Field', name: 'title', type: 'string') }
      let(:fields)      { instance_double('Fields', by_name: field, no_associations: [field]) }
      let(:attributes)  { { title: 'Hello world' } }

      subject { decorator.to_hash }

      it { is_expected.to eq({ _slug: 'sample', title: 'Hello world' }) }

    end

    describe 'text field' do

      let(:field)         { instance_double('Field', name: 'body', type: 'text') }
      let(:fields)        { instance_double('Fields', by_name: field, no_associations: [field]) }
      let(:attributes)    { { body: 'Hello world ! http://domain.tld/samples/foo.png ! <img src="/samples/bar.png" /> <div style="background: url(/samples/42.png);"/>' } }
      let(:asset_pusher)  { SimpleAssetPusher.new }

      before { allow(decorator).to receive(:__content_assets_pusher__).and_return(asset_pusher) }

      subject { decorator.to_hash }

      it 'only replaces assets wrapped by a double quotes' do
        is_expected.to eq({ _slug: 'sample', body: 'Hello world ! http://domain.tld/samples/foo.png ! <img src="done" /> <div style="background: url(done);"/>' })
        expect(asset_pusher.assets).to eq(['/samples/bar.png', '/samples/42.png'])
      end

    end

    describe 'date field' do

      let(:field)       { instance_double('Field', name: 'posted_at', type: 'date') }
      let(:fields)      { instance_double('Fields', by_name: field, no_associations: [field]) }
      let(:attributes)  { { posted_at: Chronic.parse('2015-09-26').to_date } }

      subject { decorator.to_hash }

      it { is_expected.to eq({ _slug: 'sample', posted_at: '2015-09-26' }) }

      context 'nil field' do
        let(:attributes)  { { posted_at: nil } }
        it { is_expected.to eq({}) }
      end

    end

    describe 'date time field' do

      let(:field)       { instance_double('Field', name: 'posted_at', type: 'date_time') }
      let(:fields)      { instance_double('Fields', by_name: field, no_associations: [field]) }
      let(:attributes)  { { posted_at: Chronic.parse('2015-11-11 18:00:00').to_datetime } }

      subject { decorator.to_hash }

      it { is_expected.to eq({ _slug: 'sample', posted_at: '2015-11-11T17:00:00Z' }) }

      context 'nil field' do
        let(:attributes)  { { posted_at: nil } }
        it { is_expected.to eq({}) }
      end

    end

  end

  class SimpleAssetPusher
    attr_reader :assets
    def persist(asset); (@assets ||= []).push(asset); 'done'; end
  end

end
