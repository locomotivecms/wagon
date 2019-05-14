# # encoding: utf-8

# require 'spec_helper'

# require 'locomotive/wagon/commands/push_sub_commands/push_base_command'
# require 'locomotive/wagon/commands/push_sub_commands/push_pages_command'
# require 'ostruct'

# describe Locomotive::Wagon::PushPagesCommand do

#   let(:api_response)  { [] }
#   let(:site)          { instance_double('Site', default_locale: 'en', locales: ['en'])}
#   let(:pages_api)     { instance_double('PagesAPI', fullpaths: api_response) }
#   let(:api_client)    { instance_double('ApiClient', pages: pages_api) }
#   let(:command)       { described_class.new(api_client, nil, nil, nil) }

#   before { allow(command).to receive(:current_site).and_return(site) }

#   describe '#remote_entities' do

#     let(:api_response) { [OpenStruct.new('_id' => 1, 'fullpath' => 'index', 'handle' => nil), OpenStruct.new('_id' => 2, 'fullpath' => 'about-us', 'handle' => 'about')] }

#     before { allow(command).to receive(:api_client).and_return(api_client) }

#     subject { command.send(:remote_entities) }

#     it { is_expected.to eq({ 'index' => 1, 'about-us' => 2, :about => 2 }) }

#   end

#   describe '#remote_entity_id' do

#     let(:remote_entities) { { 'index' => 1, 'about-us' => 2, :about => 2 } }
#     let(:page) { instance_double('Page', fullpath: 'about-us', handle: nil) }

#     subject { command.send(:remote_entity_id, page) }

#     before { allow(command).to receive(:remote_entities).and_return(remote_entities) }

#     it { is_expected.to eq(2) }

#     context 'if no matching fullpath, use the handle instead' do

#       let(:page) { instance_double('Page', fullpath: 'modified-about-us', handle: 'about') }

#       it { is_expected.to eq(2) }

#     end

#   end

#   describe '#remote_entities_by_id' do

#     let(:remote_entities) { { 'index' => 1, 'about-us' => 2, :about => 2 } }

#     subject { command.send(:remote_entities_by_id) }

#     before { allow(command).to receive(:remote_entities).and_return(remote_entities) }

#     it { is_expected.to eq(1 => 'index', 2 => 'about-us') }

#   end

#   describe '#remote_entity_folder_path' do

#     let(:some_id) { 1 }
#     let(:remote_entities_by_id) { { 1 => 'index', 2 => 'about-us', 3 => 'foo/bar' } }

#     before { allow(command).to receive(:remote_entities_by_id).and_return(remote_entities_by_id) }

#     subject { command.send(:remote_entity_folder_path, some_id) }

#     it { is_expected.to eq '' }

#     context 'deeper' do

#       let(:some_id) { 3 }

#       it { is_expected.to eq 'foo' }

#     end

#   end

#   describe '#can_update?' do

#     let(:handle)  { nil }
#     let(:folder)  { '' }
#     let(:locale)  { :en }
#     let(:page)    { instance_double('Page', fullpath: 'modified-about-us', folder_path: folder, handle: handle, __locale__: locale, __default_locale__: :en) }

#     subject { command.send(:can_update?, page) }

#     it { is_expected.to eq true }

#     context 'with a handle' do

#       let(:handle)          { 'about' }
#       let(:remote_entities) { { 'index' => 1, 'about-us' => 2, :about => 2 } }

#       before { allow(command).to receive(:remote_entities).and_return(remote_entities) }

#       it { is_expected.to eq true }

#       context 'but different folder' do

#         let(:folder) { 'deeper' }

#         it { is_expected.to eq false }

#       end

#     end

#     context 'another locale' do

#       let(:locale) { :fr }

#       it { is_expected.to eq true }

#     end

#   end

# end
