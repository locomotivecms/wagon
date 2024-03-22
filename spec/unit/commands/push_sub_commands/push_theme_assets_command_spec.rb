# encoding: utf-8

require 'spec_helper'

require 'locomotive/steam'
require 'locomotive/wagon/commands/push_sub_commands/push_base_command'
require 'locomotive/wagon/commands/push_sub_commands/push_theme_assets_command'

describe Locomotive::Wagon::PushThemeAssetsCommand do

  let(:command) { described_class.new(nil, nil, nil, nil) }

  describe '#replace_assets' do

    let(:content) { "body{background-image:url(/images/body.png)}" }
    let(:urls)    { { 'images/body.png' => 'http://cdn/images/body.png?42' } }

    before { command.instance_variable_set(:@remote_urls, urls) }

    subject { command.send(:replace_assets, content) }

    it { is_expected.to eq "body{background-image:url(http://cdn/images/body.png?42)}" }

    context 'font' do

      let(:content) { "@font-face{src: url(\"/fonts/external/myfont.woff?first\");}" }
      let(:urls)  { { 'fonts/external/myfont.woff' => 'http://cdn/fonts/external/myfont.woff?42' } }

      it { is_expected.to eq "@font-face{src: url(\"http://cdn/fonts/external/myfont.woff?42\");}" }

    end

    context 'no correct reference to an image' do

      let(:content) { "body{background-image:url(/somewhere/body.png)}" }

      it { is_expected.to eq "body{background-image:url(/somewhere/body.png)}" }

    end

  end

end
