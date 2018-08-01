const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const Webpack = require('webpack');

module.exports = {
  entry: ['bootstrap-loader', './javascripts/app.js'],
  output: {
    path:     path.resolve(__dirname, '../../public'),
    filename: 'javascripts/bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx|es6)$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel-loader',
        query: { presets: ['env'] }
      },
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader?modules&importLoaders=2&localIdentName=[name]__[local]__[hash:base64:5]',
          'postcss-loader',
          'sass-loader',
        ],
      },
      {
        test: /\.(woff2?|svg)$/,
        loader: 'file-loader?name=fonts/[name].[ext]&useRelativePath=false&publicPath=../'
      },
      {
        test: /\.(ttf|eot|otf)$/,
        loader: 'file-loader?name=fonts/[name].[ext]&useRelativePath=false&publicPath=../'
      },
      {
        test: /\.(gif|png|jpe?g|svg)$/i,
        use: [
          {
            loader: 'file-loader', options: {
              outputPath: 'images/',
              name: '[path][name].[ext]'
            }
          },
          { loader: 'image-webpack-loader', options: { bypassOnDebug: true } }
        ]
      }
    ]
  },
  plugins: [
    new Webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
      Tether: 'tether',
      Popper: ['popper.js', 'default'],
      Tooltip: 'exports-loader?Tooltip!bootstrap/js/dist/tooltip',
      Util: 'exports-loader?Util!bootstrap/js/dist/util',
      Dropdown: 'exports-loader?Dropdown!bootstrap/js/dist/util',
      'window.Tether': 'tether'
    }),
    new MiniCssExtractPlugin({ filename: 'stylesheets/bundle.css', allChunks: true })
  ]
};
