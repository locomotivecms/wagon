# encoding: utf-8

require 'spec_helper'

require 'locomotive/wagon/commands/push_command'

describe Locomotive::Wagon::PushCommand do

  let(:options) { {} }
  let(:command) { described_class.new('production', '.', options, nil) }

  describe '#each_resource' do

    subject do
      [].tap { |yielded| command.send(:each_resource) { |klass| yielded << klass } }
    end

    it 'yields every resource but the ones with content, by default' do
      is_expected.to eq([
        Locomotive::Wagon::PushSiteCommand,
        Locomotive::Wagon::PushContentTypesCommand,
        Locomotive::Wagon::PushPagesCommand,
        Locomotive::Wagon::PushSnippetsCommand,
        Locomotive::Wagon::PushSectionsCommand,
        Locomotive::Wagon::PushThemeAssetsCommand
      ])
    end

    context 'with :data enabled' do

      let(:options) { { data: true } }

      it 'also yields the resources with content' do
        is_expected.to include(Locomotive::Wagon::PushContentEntriesCommand, Locomotive::Wagon::PushTranslationsCommand)
      end

    end

    context 'with :resources set' do

      let(:options) { { resources: ['pages', 'snippets'] } }

      it 'only yields the listed resources' do
        is_expected.to eq([Locomotive::Wagon::PushPagesCommand, Locomotive::Wagon::PushSnippetsCommand])
      end

    end

    context 'with :skip_resources set' do

      let(:options) { { skip_resources: ['pages', 'theme_assets'] } }

      it 'yields every resource but the skipped ones' do
        is_expected.to eq([
          Locomotive::Wagon::PushSiteCommand,
          Locomotive::Wagon::PushContentTypesCommand,
          Locomotive::Wagon::PushSnippetsCommand,
          Locomotive::Wagon::PushSectionsCommand
        ])
      end

    end

    context 'with both :resources and :skip_resources set' do

      let(:options) { { resources: ['pages', 'snippets'], skip_resources: ['pages'] } }

      it ':skip_resources takes precedence over :resources' do
        is_expected.to eq([Locomotive::Wagon::PushSnippetsCommand])
      end

    end

  end

end
