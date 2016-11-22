module.exports = {
  config: {
    // default font size in pixels for all tabs
    // fontSize: 10,
    fontSize: 9,

    // font family with optional fallbacks
    // fontFamily: 'Ricty Diminished Discord',
    fontFamily: 'Fira Code',

    // terminal cursor background color (hex)
    cursorColor: 'white',
    cursorShape: 'BLOCK',

    // color of the text
    foregroundColor: '#DBE6EC',

    // terminal background color
    backgroundColor: '#2C3643',

    // border color (window, tabs)
    borderColor: '#3B444F',

    // custom css to embed in the main window
    css: '',

    // custom css to embed in the terminal window
    termCSS: '',

    // custom padding (css format, i.e.: `top right bottom left`)
    padding: '4px 12px',

    // some color overrides. see http://bit.ly/29k1iU2 for
    // the full list
    colors: [
      '#000000',
      '#5C6370',
      '#E06C75',
      '#E06C75',
      '#98C379',
      '#98C379',
      '#D19A66',
      '#D19A66',
      '#61AFEF',
      '#61AFEF',
      '#C678DD',
      '#C678DD',
      '#56B6C2',
      '#56B6C2',
      '#ABB2BF',
      '#FFFFFF'
    ]
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hypersolar`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: [
    'hypercwd',
    'hyperterm-blink',
    // 'hyper-chester',
  ],

  // in development, you can create a directory under
  // `~/.hyperterm_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: [
    'hyper-chester',
  ]
};
