const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: './javascripts/app.js',
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
        use: ['style-loader', MiniCssExtractPlugin.loader, 'css-loader', 'postcss-loader', 'sass-loader']
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
    new MiniCssExtractPlugin({ filename: 'stylesheets/bundle.css', allChunks: true })
  ]
};
