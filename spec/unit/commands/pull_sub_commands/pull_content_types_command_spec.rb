# # encoding: utf-8

# require 'spec_helper'

# require 'active_support'
# require 'active_support/core_ext'
# require 'locomotive/wagon/commands/pull_sub_commands/pull_base_command'
# require 'locomotive/wagon/commands/pull_sub_commands/pull_content_types_command'

# describe Locomotive::Wagon::PullContentTypesCommand do

#   let(:locales) { ['en'] }
#   let(:site)    { instance_double('Site', locales: locales) }
#   let(:command) { described_class.new(nil, site, nil) }

#   describe '#select_options_yaml' do

#     subject { command.send(:select_options_yaml, options) }

#     context 'the site is localized' do

#       let(:locales) { ['en', 'fr'] }
#       let(:options) { [{ 'id' => '1', 'name' => { 'en' => 'team', 'fr' => 'équipe' }, 'position' => 2 }, { 'id' => '2', 'name' => { 'en' => 'accounting', 'fr' => 'compta' }, 'position' => 1 }] }

#       it { expect(subject['en']).to eq(['accounting', 'team']) }
#       it { expect(subject['fr']).to eq(['compta', 'équipe']) }

#     end

#     context 'the site is not localized' do

#       let(:locales) { ['fr'] }
#       let(:options) { [{ 'id' => '1', 'name' => { 'fr' => 'équipe' }, 'position' => 2 }, { 'id' => '2', 'name' => {'fr' => 'compta' }, 'position' => 1 }] }

#       it { is_expected.to eq(['compta', 'équipe']) }

#     end

#   end

# end
