local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.front_end = "WebGpu"

config.use_ime = false

config.window_padding = {
    left = 0,
    right = 0,
    top = 1,
    bottom = 0,
}

config.use_fancy_tab_bar = false

config.alternate_buffer_wheel_scroll_speed = 10

-- config.font = wezterm.font 'Victor Mono'
-- config.font_size = 16.0
-- config.line_height = 0.85

-- config.font = wezterm.font 'Hack'
-- config.font_size = 16.0
-- config.line_height = 1.0

-- config.font = wezterm.font 'Fixed'
-- config.font_size = 28
-- config.line_height = 0.9

if false then
    config.font = wezterm.font 'JuliaMono'
    config.font_size = 16.0
    config.line_height = 0.95

    config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
else
    config.font = wezterm.font 'CommitMono'
    config.font_size = 16.0
    -- config.line_height = 0.95
end



-- config.force_reverse_video_cursor = true

config.colors = {
    cursor_bg = '#ff2040',
}
-- config.color_scheme = 'Monokai Remastered'
config.color_scheme = 'Pastel White (terminal.sexy)'

config.default_cursor_style = 'BlinkingBar'
config.cursor_thickness = '0.2cell'

config.hide_tab_bar_if_only_one_tab = false

config.window_background_opacity = 0.6
config.macos_window_background_blur = 64
config.text_background_opacity = 0.7

config.native_macos_fullscreen_mode = false


wezterm.on('toggle-text-bg-opacity', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.text_background_opacity then
        overrides.text_background_opacity = 0.7
    else
        overrides.text_background_opacity = nil
    end
    window:set_config_overrides(overrides)
end)

config.keys = {
    {
        key = '+',
        mods = 'CMD',
        action = wezterm.action.IncreaseFontSize,
    },
    {
        key = '-',
        mods = 'CMD',
        action = wezterm.action.DecreaseFontSize,
    },
    {
        key = 'f',
        mods = 'CMD',
        action = wezterm.action.ToggleFullScreen,
    },
    {
        key = 'B',
        mods = 'CMD',
        action = wezterm.action.EmitEvent 'toggle-text-bg-opacity',
    },
}

return config
