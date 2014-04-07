require_relative 'generators_helper'
require 'locomotive/wagon/generators/content_type'

describe Locomotive::Wagon::Generators::ContentType do

  subject { Locomotive::Wagon::Generators::ContentType.new(args, {}, {}) }
  let(:target_path) { Dir.mktmpdir }
  after { FileUtils.remove_entry_secure target_path }

  context 'regular arguments' do
    let(:args) { [ 'posts', target_path, [ 'title', 'body:text', 'published_at:date:true' ] ] }
    let(:content_type_file) { File.join target_path, 'app','content_types','posts.yml' }
    let(:expected_data) do
      {
        'name'=>'Posts', 'slug'=>'posts',
        'description'=>'A description of the content type for the editors',
        'label_field_name'=>'title', 'order_by'=>'manually',
        'fields'=>
          [
            {
              'title'=>
              {
                'label'=>'Title', 'type'=>'string',
                'required'=>true, 'hint'=>'Explanatory text displayed in the back office', 'localized'=>false
              }
            },
            {
              'body'=>
              {
                'label'=>'Body', 'type'=>'text',
                'required'=>false, 'hint'=>'Explanatory text displayed in the back office', 'localized'=>false
              }
            },
            {
              'published_at'=>
              {
                'label'=>'Published at', 'type'=>'date',
                'required'=>true, 'hint'=>'Explanatory text displayed in the back office', 'localized'=>false
              }
            }
          ]
        }
    end
    before { subject.invoke_all }

    it 'generates a content_type file' do
      File.exists?(content_type_file).should be_true
    end

    it 'generates a readable yaml file' do
      expect { YAML.load(File.read content_type_file) }.not_to raise_error
    end

    it 'creates correct fields' do
      data = YAML.load(File.read content_type_file)
      data.should eq expected_data
    end
  end
end