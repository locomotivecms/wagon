# encoding: utf-8

require 'spec_helper'

require 'locomotive/wagon/commands/pull_sub_commands/concerns/assets_concern'

describe Locomotive::Wagon::AssetsConcern do
  describe "calling replace_asset_urls" do

    let(:assets_concern) { Class.new { include Locomotive::Wagon::AssetsConcern } }
    it "identifies the assets which should be downloaded when pulling" do

      input = <<-INPUT
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/534d2a28e6439a92180009a6/UPPERCASE.CH.FILE.jpg"/></td>
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeacf7727c1bb00012e/lowercase.ch.file.jpg" /></td>
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeac086452e35000169/some_name.jpg" /></td>
        <td><img src="https://somedomain.com/sites/51277e8fc0864503db000007/assets/532a8eeac086452e35000169/some_name.JPG" /></td>
      INPUT

      parsed_urls = []
      input.force_encoding('utf-8').gsub(assets_concern::REGEX) do |url|
        parsed_urls.push url
      end

      expect(parsed_urls.count).to eq(4)
    end
  end
end
