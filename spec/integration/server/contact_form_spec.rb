# encoding: utf-8

require File.dirname(__FILE__) + '/../integration_helper'
require 'locomotive/steam/server'
require 'rack/test'

describe 'ContactForm' do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'renders the form' do
    get '/contact'
    last_response.body.should =~ /\/entry_submissions\/messages.json/
  end

  describe '#submit' do

    let(:params) { {
      'entry' => { 'name' => 'John', 'email' => 'j@doe.net', 'message' => 'Bla bla' },
      'success_callback' => '/events',
      'error_callback' => '/contact' } }
    let(:response) { post_contact_form(params, false) }
    let(:status) { response.status }

    describe 'with json request' do

      let(:response) { post_contact_form(params, true) }
      let(:entry) { JSON.parse(response.body)['message'] }

      context 'when not valid' do

        let(:params) { {} }

        it 'returns an error status' do
          response.status.should == 422
        end

        describe 'errors' do

          subject { entry['errors'] }

          it { should have_key_with_value('name', "can't not be blank") }

          it { should have_key_with_value('email', "can't not be blank") }

          it { should have_key_with_value('message', "can't not be blank") }

        end

      end

      context 'when valid' do

        it 'returns a success status' do
          response.status.should == 200
        end

      end

    end

    describe 'with html request' do

      context 'when not valid' do

        let(:params) { { 'error_callback' => '/contact' } }

        it 'returns a success status' do
          response.status.should == 200
        end

        it 'displays errors' do
          response.body.to_s.should =~ /can't not be blank/
        end

      end

      context 'when valid' do

        let(:response) { post_contact_form(params, false, true) }

        it 'returns a success status' do
          response.status.should == 200
        end

        it 'displays a success message' do
          response.body.should =~ /Thank you John/
        end

      end

    end

  end

  def post_contact_form(params, json = false, follow_redirect = false)
    url = '/entry_submissions/messages'
    url += '.json' if json
    params = params.symbolize_keys if json
    post url, params
    if follow_redirect
      follow_redirect!
    end
    last_response
  end

end
