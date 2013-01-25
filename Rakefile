#!/usr/bin/env rake
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'vcr'
require 'rspec'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'locomotive/builder'
require 'locomotive/builder/version'

gemspec = eval(File.read('locomotivecms_builder.gemspec'))
Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc 'build the gem and release it to rubygems.org'
task :release => :gem do
  sh "gem push pkg/locomotivecms_builder-#{gemspec.version}.gem"
end

namespace :development do
  task :bootstrap do
    VCR.configure do |c|
      c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/spec/integration/cassettes')
      c.hook_into :webmock # or :fakeweb
      c.allow_http_connections_when_no_cassette = true
      # c.ignore_request do |request|
      #   URI(request.uri).path =~ /translations/
      # end
    end

    FileUtils.rm_rf(File.join(File.dirname(__FILE__), 'site'))
    VCR.use_cassette('pull') do
      exit unless Locomotive::Builder.clone("site", {"host" => "http://locomotive.engine.dev:3000"}, "email" => "admin@locomotivecms.com", "password" => "locomotive")
    end

    Locomotive::Builder.push("site", {"host" => "http://locomotive.engine.dev:3000"}, "email" => "admin@locomotivecms.com", "password" => "locomotive", "force" => true, "data" => true)
  end
end
