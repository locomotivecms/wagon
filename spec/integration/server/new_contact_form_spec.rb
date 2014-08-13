# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/wagon/server'
require 'rack/test'

describe 'NewContactForm' do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'renders the form' do
    get '/events'
    last_response.body.should =~ %r(<form method="POST" enctype="multipart/form-data" id="contactform">)
  end

  describe '#submit' do

    let(:params) { {
      'content_type_slug' => 'messages',
      'entry' => { 'name' => 'John', 'email' => 'j@doe.net', 'message' => 'Bla bla' } } }
    let(:response) { post_contact_form(params) }
    let(:status) { response.status }

    context 'when not valid' do

      let(:params) { { 'content_type_slug' => 'messages' } }

      it 'returns a success status' do
        response.status.should == 200
      end

      it 'displays errors' do
        response.body.to_s.should =~ /can't not be blank/
      end

    end

    context 'when valid' do

      let(:response) { post_contact_form(params, true) }

      it 'returns a success status' do
        response.status.should == 200
      end

      it 'displays a success message' do
        response.body.should =~ /Thank you John/
      end

    end

  end

  def post_contact_form(params, follow_redirect = false)
    url = '/events'
    post url, params

    follow_redirect! if follow_redirect

    last_response
  end

end
