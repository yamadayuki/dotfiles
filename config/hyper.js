module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 11,

    // font family with optional fallbacks
    // fontFamily: 'Ricty Diminished Discord',
    fontFamily: "Operator Mono SSm",
    // fontFamily: "Fira Code",
    uiFontFamily: "Operator Mono SSm",
    fontWeight: "normal",

    // terminal cursor background color (hex)
    cursorColor: "#6C6F93",
    cursorAccentColor: "#D5D8DA",
    cursorShape: "BLOCK",
    cursorBlink: true,

    // color of the text
    foregroundColor: "#D5D8DA",

    // terminal background color
    backgroundColor: "#1C1E26",

    // border color (window, tabs)
    borderColor: "#6BE4E6",

    // custom css to embed in the main window
    css: "",

    // custom css to embed in the terminal window
    termCSS: "",

    // custom padding (css format, i.e.: `top right bottom left`)
    padding: "4px 12px",

    // some color overrides. see http://bit.ly/29k1iU2 for
    // the full list
    colors: {
      // black: "",
      red: "#E95678",
      green: "#29D398",
      yellow: "#FAB795",
      blue: "#26BBD9",
      magenta: "#EE64AC",
      cyan: "#59E1E3",
      white: "#D5D8DA",
      // lightBlack: "",
      lightRed: "#EC6A88",
      lightGreen: "#3FDAA4",
      lightYellow: "#FBC3A7",
      lightBlue: "#3FC4DE",
      lightMagenta: "#F075B5",
      lightCyan: "#6BE4E6",
      // lightWhite: "",
      colorCubes: "#6C6F934D",
      grayscale: "#D5D8DA",
    },

    shell: "/usr/local/bin/fish",
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hypersolar`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: ["hypercwd"],

  // in development, you can create a directory under
  // `~/.hyperterm_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: [],
};
