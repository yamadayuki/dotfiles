local wezterm = require 'wezterm'

return {
  font = wezterm.font({
    family = 'MonoLisa',
    weight = 'Medium',
    harfbuzz_features = {
      'zero=1',
      'liga=0',
      'ss01=0',
      'ss02=1',
      'ss03=0'
    },
  }),

  default_cursor_style = 'SteadyBlock',

  colors = {
    foreground = '#b3b1ad',
    background = '#0d1117',

    cursor_fg = '#0d1117',
    cursor_bg = 'cyan',
    cursor_border = 'cyan',

    -- selection_fg = 'black',
    -- selection_bg = '#fffacd',
    -- scrollbar_thumb = '#222222',

    split = 'cyan',

    ansi = {
      '484f58', -- black
      'ff7b72', -- red
      '3fb950', -- green
      'd29922', -- yellow
      '58a6ff', -- blue
      'bc8cff', -- magenta
      '39c5cf', -- cyan
      'b1bac4', -- white
    },

    brights = {
      '6e7681', -- black
      'ffa198', -- red
      '56d364', -- green
      'e3b341', -- yellow
      '79c0ff', -- blue
      'd2a8ff', -- magenta
      '56d4dd', -- cyan
      'f0f6fc', -- white
    },

    -- Arbitrary colors of the palette in the range from 16 to 255
    indexed = {
      [16] = '#d18616',
      [17] = '#ffa198'
    },

    -- Since: 20220319-142410-0fcdea07
    -- When the IME, a dead key or a leader key are being processed and are effectively
    -- holding input pending the result of input composition, change the cursor
    -- to this color to give a visual cue about the compose state.
    -- compose_cursor = 'orange',

    -- Colors for copy_mode and quick_select
    -- available since: 20220807-113146-c2fee766
    -- In copy_mode, the color of the active text is:
    -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
    -- 2. selection_* otherwise
    -- copy_mode_active_highlight_bg = { Color = '#000000' },
    -- use `AnsiColor` to specify one of the ansi color palette values
    -- (index 0-15) using one of the names "Black", "Maroon", "Green",
    --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
    -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
    -- copy_mode_active_highlight_fg = { AnsiColor = 'Black' },
    -- copy_mode_inactive_highlight_bg = { Color = '#52ad70' },
    -- copy_mode_inactive_highlight_fg = { AnsiColor = 'White' },

    -- quick_select_label_bg = { Color = 'peru' },
    -- quick_select_label_fg = { Color = '#ffffff' },
    -- quick_select_match_bg = { AnsiColor = 'Navy' },
    -- quick_select_match_fg = { Color = '#ffffff' },
  },

  window_frame = {
    font = wezterm.font({
      family = 'MonoLisa',
      weight = 'Medium',
      harfbuzz_features = {
        'zero=1',
        'liga=0',
        'ss01=0',
        'ss02=1',
        'ss03=0'
      },
    }),

    font_size = 12.0,
  },

  window_background_opacity = 1.0,
  hide_tab_bar_if_only_one_tab = true,
}
