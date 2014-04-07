require_relative 'generators_helper'
require 'locomotive/wagon/generators/page'

describe Locomotive::Wagon::Generators::Page do
  let(:target_path) { Dir.mktmpdir }
  before { subject.create_page }
  after { FileUtils.remove_entry_secure target_path }

  subject { Locomotive::Wagon::Generators::Page.new(args, {}, {}) }

  context 'regular arguments' do
    let(:args) { [ 'about-us', target_path, [] ] }
    let(:page_file) { File.join target_path, 'app','views','pages','about-us.liquid' }
    let(:expected_data) { { 'title'=>'About-us', 'listed'=>true, 'published'=>true } }

    it 'generates a content_type file' do
      File.exists?(page_file).should be_true
    end

    it 'generates a readable yaml file' do
      expect { YAML.load(File.read page_file) }.not_to raise_error
    end

    it 'creates correct fields' do
      data = YAML.load(File.read page_file)
      data.should eq expected_data
    end
  end

  context 'multiple locales' do
    let(:args) { [ 'about-us', target_path, ['fr','en'] ] }
    let(:page_file_names) { ['about-us.liquid', 'about-us.fr.liquid', 'about-us.en.liquid'] }
    it 'creates one file per locale , plus default page' do
      page_file_names.each do |page_file|
        File.exists?(File.join target_path, 'app','views','pages', page_file).should be_true
      end
    end

    it 'translated pages have their own slug' do
      english_file = File.join target_path, 'app','views','pages', 'about-us.en.liquid'
      data = YAML.load(File.read english_file)
      data['slug'].should_not be_empty
    end
  end
end