# encoding: utf-8

require 'locomotive/wagon/liquid'

describe Locomotive::Wagon::Liquid::Drops::Page do

  let(:attributes) { { title: "Hello world" } }
  let(:source) { Locomotive::Mounter::Models::Page.new(attributes) }

  subject { source.to_liquid }

  describe 'the title' do

    its(:title) { should eq "Hello world" }

  end

  describe 'with editable elements' do

    let(:text_a) { Locomotive::Mounter::Models::EditableElement.new(block: 'sidebar/header', slug: 'ads', content: 'foo' ) }
    let(:text_b) { Locomotive::Mounter::Models::EditableElement.new(block: 'sidebar/footer', slug: 'ads', content: 'foo ter' ) }
    let(:text_c) { Locomotive::Mounter::Models::EditableElement.new(block: '', slug: 'simple_text', content: 'bar' ) }
    let(:text_d) { Locomotive::Mounter::Models::EditableElement.new(block: 'My footer/wrapper/inner', slug: 'text', content: 'hello world' ) }
    let(:attributes) { { editable_elements: [text_a, text_b, text_c, text_d] } }

    its(:editable_elements) do
      should eq({
        'sidebar' => {
          'header' => { 'ads' => 'foo' },
          'footer' => { 'ads' => 'foo ter' }
        },
        'simple_text' => 'bar',
        'my_footer' => {
          'wrapper' => { 'inner' => { 'text' => 'hello world' } }
        }
      })
    end

  end

end