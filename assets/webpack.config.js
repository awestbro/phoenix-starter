const webpack = require("webpack");
const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyWebpackPlugin = require('copy-webpack-plugin');
const supportedBrowsers = require("./browsers");

const paths = {
  static: path.join(__dirname, "../priv/static"),
  build: path.join(__dirname, "../priv/static/dist"),
  node_modules: path.join(__dirname, "./node_modules"),
  src: path.join(__dirname, "./"),
}
const webpackConfig = {
  context: process.cwd(),
  entry: {
    'app': ["babel-polyfill", path.join(paths.src, "js/app.js")],
    'individual': [path.join(paths.src, "js/pages/individual.js")],
    'css': path.join(paths.src, "scss/app.scss"),
  },
  output: {
    path: paths.build,
    filename: "[name].js",
  },
  resolve: {
    extensions: [".js", ".jsx"],
    symlinks: false,
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "app.css",
    }),
    new CopyWebpackPlugin([{
      from: path.join(paths.src, 'static'),
      to: paths.static
    }, {
      from: 'node_modules/unpoly/dist/unpoly.min.js',
      to: paths.build,
    }, {
      from: 'node_modules/unpoly/dist/unpoly.min.css',
      to: paths.build,
    }])
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules)/,
        use: {
          loader: "babel-loader",
          options: {
            presets: [
              ["env", {
                targets: {
                  browsers: supportedBrowsers,
                },
              }],
            ],
            plugins: [
              ["transform-object-rest-spread", { useBuiltIns: true }],
            ],
          },
        },
      },
      {
        test: /\.scss$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          "css-loader?importLoaders=1&minimize&sourceMap&-autoprefixer",
          "postcss-loader",
          "sass-loader",
        ],
      },

    ],
  },
  devServer: {
    publicPath: "/",
  },
};

module.exports = webpackConfig;
