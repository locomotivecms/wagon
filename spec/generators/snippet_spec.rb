require_relative 'generators_helper'
require 'locomotive/wagon/generators/snippet'

describe Locomotive::Wagon::Generators::Snippet do
  let(:target_path) { Dir.mktmpdir }
  before { subject.create_snippet }
  after { FileUtils.remove_entry_secure target_path }

  subject { Locomotive::Wagon::Generators::Snippet.new(args, {}, {}) }

  context 'regular arguments' do
    let(:args) { [ 'weather-forecast', target_path, [] ] }
    let(:snippet_file) { File.join target_path, 'app','views','snippets','weather_forecast.liquid' }
    let(:expected_data) { { 'title'=>'About-us', 'listed'=>true, 'published'=>true } }

    it 'generates a snippet file' do
      File.exists?(snippet_file).should be_true
    end
  end
end