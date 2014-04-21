require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'vcr'
require 'rspec'
require 'rspec/core/rake_task'

require 'locomotive/wagon'
require 'locomotive/wagon/version'

namespace :development do
  desc 'create vcr cassettes'
  task :bootstrap do
    VCR.configure do |c|
      c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/spec/integration/cassettes')
      c.hook_into :webmock # or :fakeweb
      c.allow_http_connections_when_no_cassette = true
    end

    FileUtils.rm_rf(File.join(File.dirname(__FILE__), 'site'))
    VCR.use_cassette('pull') do
      exit unless Locomotive::Wagon.clone('site', '.', { host: 'sample.example.com:3000', email: 'admin@locomotivecms.com', password: 'locomotive' })
    end

    Locomotive::Wagon.push('site', {host: 'sample.example.com:3000', email: 'admin@locomotivecms.com', password: 'locomotive'}, force: true, translations: false, data: true)
  end
end

RSpec::Core::RakeTask.new('spec')

task default: :spec
