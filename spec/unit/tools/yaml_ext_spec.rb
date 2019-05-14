# # encoding: utf-8

# require 'spec_helper'

# require_relative '../../../lib/locomotive/wagon/tools/yaml_ext.rb'

# describe Locomotive::Wagon::YamlExt do

#   describe '.transform' do

#     let(:hash)  { nil }
#     let(:block) { -> (value) { value + '!' } }

#     subject { described_class.transform(hash, &block); hash }

#     it { expect(subject).to eq nil }

#     describe 'simple hash' do

#       let(:hash) { { 'foo' => 'a', 'bar' => 'b' } }

#       it { expect(subject['foo']).to eq 'a!' }
#       it { expect(subject['bar']).to eq 'b!' }

#     end

#     describe 'hash of hashes' do

#       let(:hash) { { 'foo' => { 'bar' => 'a' } } }

#       it { expect(subject['foo']['bar']).to eq 'a!' }

#     end

#     describe 'hash with an array' do

#       let(:hash) { { 'foo' => [{ 'bar' => 'a' }, 2] } }

#       it { expect(subject['foo'][0]['bar']).to eq 'a!' }

#     end


#   end

# end
