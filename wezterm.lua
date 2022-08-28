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
    foreground = '#d5d8da',
    background = '#1c1e26',

    cursor_fg = '#1c1e26',
    cursor_bg = 'cyan',
    cursor_border = 'cyan',

    -- selection_fg = 'black',
    -- selection_bg = '#fffacd',
    -- scrollbar_thumb = '#222222',

    split = 'cyan',

    ansi = {
      '1d1f21', -- black
      'e95678', -- red
      '29d398', -- green
      'fab795', -- yellow
      '26bbd9', -- blue
      'ee64ac', -- magenta
      '59e1e3', -- cyan
      'd5d8da', -- white
    },

    brights = {
      '666666', -- black
      'ec6a88', -- red
      '3fdaa4', -- green
      'fbc3a7', -- yellow
      '3fc4de', -- blue
      'f075b5', -- magenta
      '6be4e6', -- cyan
      'd5d8da', -- white
    },

    -- Arbitrary colors of the palette in the range from 16 to 255
    -- indexed = { [136] = '#af8700' },

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
