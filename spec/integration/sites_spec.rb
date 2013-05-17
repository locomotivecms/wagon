# encoding: utf-8

require File.dirname(__FILE__) + '/integration_helper'

describe Locomotive::Wagon do
  it 'imports' do
    File.exists?('site/config/site.yml').should be_false
    clone_site
    YAML.load_file('site/config/site.yml').should == {
      'name'      =>'locomotive',
      'locales'   =>['en', 'es'],
      'subdomain' =>'sample',
      'domains'   =>['sample.example.com']
    }
  end

  it 'pushes' do
    clone_site
    file_name = File.dirname(__FILE__) + '/../../site/app/views/pages/index.liquid'
    text = File.read(file_name)
    text.gsub!(/Content of the home page/, 'New content of the home page')
    File.open(file_name, 'w') { |file| file.puts text}
    VCR.use_cassette('push') do
      Locomotive::Wagon.push('site', { host: 'sample.example.com:3000', email: 'admin@locomotivecms.com', password: 'locomotive' })
    end
    WebMock.should have_requested(:put, /pages\/.+.json\?auth_token=.+/).with(body: /page\[raw_template\]=New%20content%20of%20the%20home%20page/).once
  end
  
  describe "push with unrecognized resources" do
    subject do
      lambda do
        clone_site
        VCR.use_cassette('push') do
          Locomotive::Wagon.push('site', { host: 'sample.example.com:3000', email: 'admin@locomotivecms.com', password: 'locomotive' }, {resources: ['all']})
        end
      end
    end
    
    it { should raise_exception(ArgumentError, "'all' resource not recognized") }
  end
end