# encoding: utf-8

require 'spec_helper'
require 'ostruct'

require 'locomotive/wagon/decorators/concerns/to_hash_concern'
require 'locomotive/wagon/decorators/site_decorator'

describe Locomotive::Wagon::SiteDecorator do

  let(:site) { instance_double('Site', attributes) }
  let(:decorator) { described_class.new(site) }

  describe '#domains' do

    let(:attributes) { { domains: ['acme.com', 'localhost'] } }

    subject { decorator.domains }

    it { is_expected.to eq ['acme.com'] }

  end

  describe '#to_hash' do

    let(:seo_title) { instance_double('I18nField', translations: { en: 'Hi', fr: 'Bonjour' }) }
    let(:attributes) { { name: 'Acme', handle: nil, seo_title: seo_title, locales: nil } }
    let(:site) { OpenStruct.new(attributes) }

    subject { decorator.to_hash }

    it { is_expected.to eq(name: 'Acme', seo_title: { en: 'Hi', fr: 'Bonjour' }) }

  end

end
