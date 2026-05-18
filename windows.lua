local wezterm = require("wezterm")
local act = wezterm.action

-- Machine-local settings
local machine = {
  background_image = wezterm.home_dir .. "/Pictures/Backgrounds/terminal-background-d20.png",
  default_shell = { "powershell.exe", "-NoLogo" },
}

local function clean_title(title)
  return title:gsub("%.exe$", "")
end

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
  return clean_title(pane:get_title())
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title

  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  return " " .. clean_title(title) .. " "
end)

local config = {}
local manual_tab_bar = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

wezterm.on("toggle-decorations", function(window, pane)
  local overrides = window:get_config_overrides() or {}

  if overrides.window_decorations == "TITLE|RESIZE" then
    overrides.window_decorations = "NONE"
  else
    overrides.window_decorations = "TITLE|RESIZE"
  end

  window:set_config_overrides(overrides)
end)

wezterm.on("toggle-tab-bar", function(window, pane)
  local window_id = window:window_id()
  manual_tab_bar[window_id] = not manual_tab_bar[window_id]

  local overrides = window:get_config_overrides() or {}
  overrides.enable_tab_bar = manual_tab_bar[window_id]
  overrides.hide_tab_bar_if_only_one_tab = not manual_tab_bar[window_id]

  window:set_config_overrides(overrides)
end)
config.disable_default_key_bindings = true

config.keys = {
  {key = "s", mods = "CTRL|SHIFT", action = act.ShowLauncher, },
  { key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo "Clipboard", },
  { key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom "Clipboard", },
  -- tab navigation
  { key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
  { key = "Enter", mods = "ALT|SHIFT", action = act.EmitEvent("toggle-decorations") },
  { key = "b", mods = "ALT|SHIFT", action = act.EmitEvent("toggle-tab-bar") },
  { key = "Space", mods = "ALT|SHIFT", action = act.QuickSelect },
  {
    key = "n",
    mods = "ALT|SHIFT",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  
}

wezterm.on("update-status", function(window, pane)
  local mux_window = window:mux_window()
  local tabs = mux_window:tabs()

  local low_battery = false
  local battery_status = ""

  for _, battery in ipairs(wezterm.battery_info()) do
    low_battery = low_battery or battery.state_of_charge < 0.5

    if battery.state == "Discharging" then
      local battery_color = "#9ece6a"
      local show_battery_percent = false

      if battery.state_of_charge < 0.15 then
        battery_color = "#f7768e"
        show_battery_percent = true
      elseif battery.state_of_charge < 0.3 then
        battery_color = "#ff9e64"
        show_battery_percent = true
      elseif battery.state_of_charge < 0.5 then
        battery_color = "#e0af68"
      end

      local battery_segments = {}

      if show_battery_percent then
        table.insert(battery_segments, { Text = string.format("%.0f%%", battery.state_of_charge * 100) })
      end

      table.insert(battery_segments, { Foreground = { Color = battery_color } })
      table.insert(battery_segments, { Text = " ■" })
      table.insert(battery_segments, "ResetAttributes")

      battery_status = wezterm.format(battery_segments)
      break
    end
  end

  local overrides = window:get_config_overrides() or {}
  local desired_tab_bar = manual_tab_bar[window:window_id()] or low_battery or (#tabs >= 3)
  local desired_hide_single_tab = not manual_tab_bar[window:window_id()]

  if overrides.enable_tab_bar ~= desired_tab_bar or overrides.hide_tab_bar_if_only_one_tab ~= desired_hide_single_tab then
    overrides.enable_tab_bar = desired_tab_bar
    overrides.hide_tab_bar_if_only_one_tab = desired_hide_single_tab
    window:set_config_overrides(overrides)
  end

  window:set_right_status(battery_status)
end)

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.allow_win32_input_mode = false
config.enable_csi_u_key_encoding = true

-- config.font = wezterm.font_with_fallback({
-- 	"CaskaydiaCove Nerd Font",
-- 	"Cascadia Code",
--   })

config.font_size = 14

config.color_scheme = "Tokyo Night Moon"

config.scrollback_lines = 1000

-- Enable all ligatures
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1", "dlig=1" }

config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 2,
}

config.window_decorations = "RESIZE"

config.background = {
  {
    source = {
      File = machine.background_image,
    },
    width = "Cover",
    height = "Cover",
    horizontal_align = "Center",
    vertical_align = "Middle",
    opacity = 1,
  },
}

config.launch_menu = {
  {
    label = "PowerShell",
    args = machine.default_shell,
  },
}

config.default_prog = machine.default_shell

return config
