# # encoding: utf-8

# require 'spec_helper'
# require 'ostruct'

# require 'locomotive/wagon/decorators/concerns/to_hash_concern'
# require 'locomotive/wagon/decorators/concerns/persist_assets_concern'
# require 'locomotive/steam/decorators/template_decorator'
# require 'locomotive/wagon/decorators/page_decorator'

# describe Locomotive::Wagon::PageDecorator do

#   let(:page) { instance_double('Page', attributes) }
#   let(:decorator) { described_class.new(page, 'en', nil, nil) }

#   describe '#folder_path' do

#     let(:fullpath) { 'index' }
#     let(:attributes) { { fullpath: fullpath, localized_attributes: [] } }

#     subject { decorator.folder_path }

#     it { is_expected.to eq '' }

#     context 'deeper' do

#       let(:fullpath) { 'foo/bar' }

#       it { is_expected.to eq 'foo' }

#     end

#   end

# end
