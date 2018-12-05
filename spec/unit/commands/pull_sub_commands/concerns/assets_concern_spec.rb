# encoding: utf-8

require 'spec_helper'

require 'active_support'
require 'active_support/core_ext'
require 'locomotive/wagon/commands/pull_sub_commands/concerns/assets_concern'

describe Locomotive::Wagon::AssetsConcern do

  let(:concern) { Class.new { include Locomotive::Wagon::AssetsConcern; def path; 'tmp'; end; def env; 'production'; end; } }

  describe "calling replace_asset_urls" do

    it "identifies the assets which should be downloaded when pulling" do
      input = <<-INPUT
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/534d2a28e6439a92180009a6/UPPERCASE.CH.FILE.jpg"/></td>
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeacf7727c1bb00012e/lowercase.ch.file.jpg" /></td>
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeac086452e35000169/some_name.jpg" /></td>
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeac086452e35000169/some_name.JPG" /></td>
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/pages/532a8eeac086452e35000169/header.JPG?42" /></td>
      INPUT

      parsed_urls = []
      input.force_encoding('utf-8').gsub(concern::REGEX) do |url|
        parsed_urls.push url
      end

      expect(parsed_urls.count).to eq(5)
    end
  end


  describe '#replace_asset_urls' do

    let(:content)   { %(<td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeac086452e35000169/some_name.JPG?42" /></td>) }
    let(:instance)  { concern.new }

    subject { instance.replace_asset_urls(content) }

    it 'removes the query string' do
      expect(instance).to receive(:write_asset).with("https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeac086452e35000169/some_name.JPG?42", "tmp/public/samples/_production/assets/some_name.JPG").and_return('some_name.JPG')
      is_expected.to eq %(<td><img src="/samples/_production/assets/some_name.JPG" /></td>)
    end

  end

end
