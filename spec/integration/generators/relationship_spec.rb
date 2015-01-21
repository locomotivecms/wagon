# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'

require 'locomotive/wagon'
require 'locomotive/wagon/cli'

describe 'Locomotive::Wagon::Generators::Relationship' do

  before(:all)      { make_working_copy_of_site(:blog) }
  after(:all)       { remove_working_copy_of_site(:blog) }

  let(:path)        { working_copy_of_site(:blog) }
  let(:source_slug) { 'comments' }
  let(:target_slug) { 'posts' }
  let(:type)        { 'belongs_to' }
  let(:options)     { { 'force_color' => true, 'path' => path, 'quiet' => true } }

  subject { Locomotive::Wagon.generate(:relationship, [source_slug, type, target_slug, options.delete('path')], options) }

  describe 'wrong parameters' do

    describe 'unknown slugs' do

      let(:source_slug) { 'authors' }

      it { lambda { subject }.should raise_error 'The authors content type does not exist' }

    end

    describe 'unknown type' do

      let(:type) { 'has_one' }

      it { lambda { subject }.should raise_error 'has_one is an unknown relationship type' }

    end

  end

  describe 'generating a belongs_to relationship' do

    before { subject }

    it 'adds code to the source content type' do
      read_content_type(:comments).should include <<-EXPECTED
- post:
    label: Post
    type: belongs_to
    class_name: posts
EXPECTED
    end

    it 'adds code the target content type' do
      read_content_type(:posts).should include <<-EXPECTED
- comments:
    label: Comments
    type: has_many
    class_name: comments
    inverse_of: post
EXPECTED
    end

  end

  describe 'generating a many_to_many relationship' do

    before      { subject }

    let(:type)  { 'many_to_many' }

    it 'adds code to the source content type' do
      read_content_type(:comments).should include <<-EXPECTED
- posts:
    label: Posts
    type: many_to_many
    class_name: posts
    inverse_of: comments
EXPECTED
    end

    it 'adds code the target content type' do
      read_content_type(:posts).should include <<-EXPECTED
- comments:
    label: Comments
    type: many_to_many
    class_name: comments
    inverse_of: posts
EXPECTED
    end

  end

  def read_content_type(name)
    File.read(File.join(path, 'app', 'content_types', "#{name}.yml"))
  end

end
