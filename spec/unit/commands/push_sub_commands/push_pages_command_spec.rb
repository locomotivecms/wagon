# encoding: utf-8

require 'spec_helper'

require 'active_support/notifications'
require 'locomotive/coal'
require 'locomotive/wagon/commands/push_sub_commands/push_base_command'
require 'locomotive/wagon/commands/push_sub_commands/push_pages_command'
require 'ostruct'

describe Locomotive::Wagon::PushPagesCommand do

  let(:api_response)  { [] }
  let(:site)          { instance_double('Site', default_locale: 'en', locales: ['en'])}
  let(:pages_api)     { instance_double('PagesAPI', fullpaths: api_response) }
  let(:api_client)    { instance_double('ApiClient', pages: pages_api) }
  let(:command)       { described_class.new(api_client, nil, nil, nil) }

  before { allow(command).to receive(:current_site).and_return(site) }

  # Builds a real Locomotive::Coal::InvalidResourceError whose #message matches what the
  # engine actually sends back, eg: invalid_resource_error('handle has already been taken')
  # => "Resource invalid: handle has already been taken"
  def invalid_resource_error(message)
    field, description = message.split(' ', 2)
    response = double('Response', body: { 'error' => 'Resource invalid', 'attributes' => { field => [description] } })
    Locomotive::Coal::InvalidResourceError.new(response)
  end

  describe '#remote_entities' do

    let(:api_response) { [OpenStruct.new('_id' => 1, 'fullpath' => 'index', 'handle' => nil), OpenStruct.new('_id' => 2, 'fullpath' => 'about-us', 'handle' => 'about')] }

    before { allow(command).to receive(:api_client).and_return(api_client) }

    subject { command.send(:remote_entities) }

    it { is_expected.to eq({ 'index' => 1, 'about-us' => 2, :about => 2 }) }

  end

  describe '#remote_entity_id' do

    let(:remote_entities) { { 'index' => 1, 'about-us' => 2, :about => 2 } }
    let(:page) { instance_double('Page', fullpath: 'about-us', handle: nil) }

    subject { command.send(:remote_entity_id, page) }

    before { allow(command).to receive(:remote_entities).and_return(remote_entities) }

    it { is_expected.to eq(2) }

    context 'if no matching fullpath, use the handle instead' do

      let(:page) { instance_double('Page', fullpath: 'modified-about-us', handle: 'about') }

      it { is_expected.to eq(2) }

    end

  end

  describe '#remote_entities_by_id' do

    let(:remote_entities) { { 'index' => 1, 'about-us' => 2, :about => 2 } }

    subject { command.send(:remote_entities_by_id) }

    before { allow(command).to receive(:remote_entities).and_return(remote_entities) }

    it { is_expected.to eq(1 => 'index', 2 => 'about-us') }

  end

  describe '#remote_entity_folder_path' do

    let(:some_id) { 1 }
    let(:remote_entities_by_id) { { 1 => 'index', 2 => 'about-us', 3 => 'foo/bar' } }

    before { allow(command).to receive(:remote_entities_by_id).and_return(remote_entities_by_id) }

    subject { command.send(:remote_entity_folder_path, some_id) }

    it { is_expected.to eq '' }

    context 'deeper' do

      let(:some_id) { 3 }

      it { is_expected.to eq 'foo' }

    end

  end

  describe '#can_update?' do

    let(:handle)  { nil }
    let(:folder)  { '' }
    let(:locale)  { :en }
    let(:page)    { instance_double('Page', fullpath: 'modified-about-us', folder_path: folder, handle: handle, __locale__: locale, __default_locale__: :en) }

    subject { command.send(:can_update?, page) }

    it { is_expected.to eq true }

    context 'with a handle' do

      let(:handle)          { 'about' }
      let(:remote_entities) { { 'index' => 1, 'about-us' => 2, :about => 2 } }

      before { allow(command).to receive(:remote_entities).and_return(remote_entities) }

      it { is_expected.to eq true }

      context 'but different folder' do

        let(:folder) { 'deeper' }

        it { is_expected.to eq false }

      end

    end

    context 'another locale' do

      let(:locale) { :fr }

      it { is_expected.to eq true }

    end

  end

  describe '#persist' do

    let(:decorated_entity) { double('DecoratedPage', fullpath: 'cosanum', to_hash: { handle: 'cosanum' }) }

    subject { command.persist(decorated_entity) }

    before do
      allow(decorated_entity).to receive(:_id=)
      allow(command).to receive(:remote_entity_id).with(decorated_entity).and_return(remote_id)
      allow(command).to receive(:translated_in).with(decorated_entity).and_yield(:en)
    end

    context 'when the page does not exist remotely yet' do

      let(:remote_id) { nil }

      it 'creates it' do
        expect(pages_api).to receive(:create).with(decorated_entity.to_hash).and_return(OpenStruct.new('_id' => 42))
        subject
      end

      context 'but the remote engine rejects it because the handle is already taken' do

        before { allow(pages_api).to receive(:create).and_raise(invalid_resource_error('handle has already been taken')) }

        it 'skips it instead of aborting the whole deploy' do
          expect { subject }.to raise_error(Locomotive::Wagon::PushBaseCommand::SkipPersistingException)
        end

      end

      context 'and the remote engine rejects it for another reason' do

        before { allow(pages_api).to receive(:create).and_raise(invalid_resource_error('slug is invalid')) }

        it 'raises the original error' do
          expect { subject }.to raise_error(Locomotive::Coal::InvalidResourceError, /slug is invalid/)
        end

      end

    end

    context 'when the page already exists remotely' do

      let(:remote_id) { 42 }

      context 'and it is safe to update (same folder)' do

        before { allow(command).to receive(:can_update?).with(decorated_entity).and_return(true) }

        it 'updates it' do
          expect(pages_api).to receive(:update).with(remote_id, decorated_entity.to_hash, :en)
          subject
        end

      end

      context 'but a remote page with the same handle lives in a different folder' do

        before do
          allow(command).to receive(:can_update?).with(decorated_entity).and_return(false)
          allow(command).to receive(:remote_entity_fullpath_from_handle).with(decorated_entity).and_return('other-folder/cosanum')
        end

        it 'skips it with a warning instead of aborting the whole deploy' do
          expect(pages_api).not_to receive(:update)
          expect { subject }.to raise_error(Locomotive::Wagon::PushBaseCommand::SkipPersistingException)
        end

      end

    end

  end

  describe '#handle_taken?' do

    subject { command.send(:handle_taken?, error) }

    context 'when the handle uniqueness constraint failed' do

      let(:error) { invalid_resource_error('handle has already been taken') }

      it { is_expected.to be_truthy }

    end

    context 'for any other validation error' do

      let(:error) { invalid_resource_error('slug is invalid') }

      it { is_expected.to be_falsey }

    end

  end

end
