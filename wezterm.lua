local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.automatically_reload_config = true

-- Font
config.font = wezterm.font 'MonoLisa Variable'
config.font_size = 14.0

-- Enable IME for Japanese
config.use_ime = true

-- Colors
config.colors = {
  background = "#000000",
  foreground = "#e6edf3",

  ansi = {
    "#484f58",
    "#ff7b72",
    "#3fb950",
    "#d29922",
    "#58a6ff",
    "#bc8cff",
    "#39c5cf",
    "#b1bac4",
  },

  brights = {
    "#6e7681",
    "#ffa198",
    "#56d364",
    "#e3b341",
    "#79c0ff",
    "#d2a8ff",
    "#56d4dd",
    "#ffffff",
  },

  tab_bar = {
    inactive_tab_edge = "none",
  }
}

-- Window
config.window_background_opacity = 0.7
config.macos_window_background_blur = 20

-- Title bar
config.window_decorations = "RESIZE"
config.tab_max_width = 32

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",

  font = wezterm.font('Inter', { weight = "Regular" }),
  font_size = 14.0,
}
config.window_background_gradient = {
  colors = {
    "#000000",
  }
}
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false

local SOLID_LEFT = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = tab.is_active and "#000000" or "#1e222a"
  local foreground = tab.is_active and "#e6edf3" or "#6e7681"
  local edge_background = "none"
  local edge_foreground = background

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT },

    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. wezterm.truncate_right(tab.active_pane.title, max_width ) .. " " },

    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT },
  }
end)

return config
