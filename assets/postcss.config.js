const supportedBrowsers = require("./browsers");

module.exports = {
  plugins: [
    require("autoprefixer")({
      browsers: supportedBrowsers,
      flexbox: true,
    }),
    require("postcss-flexbugs-fixes"),
  ],
}
