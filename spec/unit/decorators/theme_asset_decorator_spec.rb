# # encoding: utf-8

# require 'spec_helper'
# require 'ostruct'

# require 'locomotive/wagon/decorators/concerns/to_hash_concern'
# require 'locomotive/wagon/decorators/theme_asset_decorator'

# describe Locomotive::Wagon::ThemeAssetDecorator do

#   let(:filepath)  { '/somewhere/mysite/public/stylesheets/application.css' }
#   let(:asset)     { instance_double('Asset', source: filepath) }
#   let(:decorator) { described_class.new(asset) }

#   describe '#realname' do

#     subject { decorator.realname }

#     describe 'no extension' do
#       let(:filepath) { '/somewhere/mysite/public/stylesheets/application' }
#       it { is_expected.to eq 'application' }
#     end

#     describe 'css' do

#       it { is_expected.to eq 'application.css' }

#       describe 'scss extension' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/application.scss' }
#         it { is_expected.to eq 'application.css' }
#       end

#       describe 'css.scss extension' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/application.css.scss' }
#         it { is_expected.to eq 'application.css' }
#       end

#       describe 'sass extension' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/application.sass' }
#         it { is_expected.to eq 'application.css' }
#       end

#       describe 'css.sass extension' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/application.css.sass' }
#         it { is_expected.to eq 'application.css' }
#       end

#       describe 'less extension' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/application.less' }
#         it { is_expected.to eq 'application.css' }
#       end

#       describe 'css.less extension' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/application.css.less' }
#         it { is_expected.to eq 'application.css' }
#       end

#       describe 'jquery.pluginXy.css' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/jquery.pluginXy.css' }
#         it { is_expected.to eq 'jquery.pluginXy.css' }
#       end

#       describe 'jquery.pluginXy.css.scss' do
#         let(:filepath) { '/somewhere/mysite/public/stylesheets/jquery.pluginXy.css' }
#         it { is_expected.to eq 'jquery.pluginXy.css' }
#       end

#     end

#     describe 'js' do

#       let(:filepath) { '/somewhere/mysite/public/javascripts/application.js' }
#       it { is_expected.to eq 'application.js' }

#       describe 'coffee extension' do
#         let(:filepath) { '/somewhere/mysite/public/javascripts/application.coffee' }
#         it { is_expected.to eq 'application.js' }
#       end

#       describe 'js.coffee extension' do
#         let(:filepath) { '/somewhere/mysite/public/javascripts/application.js.coffee' }
#         it { is_expected.to eq 'application.js' }
#       end

#     end

#   end

# end
