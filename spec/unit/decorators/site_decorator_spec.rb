# encoding: utf-8

require 'spec_helper'
require 'ostruct'

require 'locomotive/wagon/decorators/concerns/to_hash_concern'
require 'locomotive/wagon/decorators/concerns/persist_assets_concern'
require 'locomotive/steam/decorators/i18n_decorator'
require 'locomotive/wagon/decorators/site_decorator'

describe Locomotive::Wagon::SiteDecorator do

  let(:site) { instance_double('Site', attributes) }
  let(:decorator) { described_class.new(site) }

  describe '#domains' do

    let(:attributes) { { domains: ['acme.com', 'localhost'], default_locale: 'en', localized_attributes: [] } }

    subject { decorator.domains }

    it { is_expected.to eq ['acme.com'] }

  end

  describe '#to_hash' do

    let(:seo_title)   { instance_double('I18nField', translations: { en: 'Hi', fr: 'Bonjour' }) }
    let(:attributes)  { { name: 'Acme', handle: nil, seo_title: seo_title, locales: nil, default_locale: 'en', localized_attributes: [] } }
    let(:site)        { OpenStruct.new(attributes) }

    subject { decorator.to_hash }

    it { is_expected.to eq(name: 'Acme', seo_title: { en: 'Hi', fr: 'Bonjour' }) }

    context 'with image metafields' do

      let(:metafields)    { { some: 'Acme', img: '/samples/42.png', img2: '/samples/bar.png' } }
      let(:schema)        { { some: { label: 'Some', type: 'string' }, img: { label: 'img', type: 'image' }, img2: { label: 'img2', type: 'image' } } }
      let(:attributes)    { { name: 'Acme', handle: nil, seo_title: seo_title, locales: nil, metafields: metafields, metafields_schema: schema, default_locale: 'en', localized_attributes: [] } }
      let(:asset_pusher)  { SimpleAssetPusher.new }

      before { allow(decorator).to receive(:__content_assets_pusher__).and_return(asset_pusher) }

      it 'only replaces assets wrapped by a double quotes' do
        expect(decorator.metafields).to eq(metafields.to_json)
        is_expected.to eq(name: 'Acme', seo_title: { en: 'Hi', fr: 'Bonjour' },
                          metafields:         metafields.to_json,
                          metafields_schema:  schema.to_json)
        expect(asset_pusher.assets).to eq(['/samples/42.png', '/samples/bar.png'])
      end

    end

  end

  class SimpleAssetPusher
    attr_reader :assets
    def persist(asset); (@assets ||= []).push(asset); 'done'; end
  end

end
