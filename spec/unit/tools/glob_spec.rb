# encoding: utf-8

require 'spec_helper'

require_relative '../../../lib/locomotive/wagon/tools/glob.rb'

describe Locomotive::Wagon::Glob do

  let(:string)    { '' }
  let(:instance)  { described_class.new(string) }

  describe "#to_regexp" do

    subject { instance.to_regexp }

    describe '**/*.css' do

      let(:string) { '**/*.css' }

      it { expect(subject.match('foo/bar/test.css')).not_to eq nil }

    end

  end

end
