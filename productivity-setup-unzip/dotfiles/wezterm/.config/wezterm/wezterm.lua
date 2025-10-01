local wezterm = require 'wezterm'
return {
  font = wezterm.font_with_fallback({ { family = "JetBrainsMono Nerd Font", weight = "Regular" }, "Apple Color Emoji" }),
  font_size = 13.0,
  harfbuzz_features = { "calt=1", "liga=1", "clig=1" },
  color_scheme = "Catppuccin Mocha",
  window_decorations = "RESIZE",
  enable_tab_bar = true,
  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  window_padding = { left=6, right=6, top=6, bottom=6 },
  default_prog = { "/bin/zsh", "-l" },
  audible_bell = "Disabled",
  check_for_updates = false,
}
