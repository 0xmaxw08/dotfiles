-- Variables

local Mod = "SUPER"
local menu = "wofi --show drun"
local term = "kitty"
local bar = "waybar"
local file = "dolphin"

-- Binds
hl.bind(Mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(Mod .. " + M", hl.dsp.exec_cmd("/home/max/.local/bin/wofi-power.sh"))  
hl.bind(Mod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/fan-toggle.sh"))
hl.bind(Mod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(Mod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(Mod .. " + Q", hl.dsp.window.close())
hl.bind(Mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(
    Mod .. " + SHIFT + F", 
    hl.dsp.window.fullscreen_state({ internal = 1, client = 0, action = "toggle" })
)
hl.bind(Mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(Mod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/waybar/wallpaper-back.sh"))
hl.bind(Mod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Utilities

hl.bind(Mod .. " + B", hl.dsp.exec_cmd("~/.config/waybar/toggle.sh"))
hl.bind(Mod .. " + SHIFT + B", hl.dsp.exec_cmd("killall waybar"))
hl.bind(Mod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(Mod .. " + E", hl.dsp.exec_cmd(file))
hl.bind(Mod .. " + grave", hl.dsp.exec_cmd('sh -c "wofi --show run --term=kitty"'))
hl.bind(Mod .. " + SHIFT + L", hl.dsp.exec_cmd("~/.local/bin/screensaver.sh"))
hl.bind(Mod .. " + SHIFT + Z", hl.dsp.exec_cmd("~/.local/bin/screensaver.sh"))
hl.bind(Mod .. " + SHIFT + Z", hl.dsp.exec_cmd("~/.local/bin/launch-screensaver.sh"))
hl.bind(Mod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/gaps-toggle.sh"))

-- Multimedia

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -s set 1%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -s set 1%-"), { repeating = true })
--hl.bind("Print", hl.dsp.exec_cmd("/home/max/.local/bin/screenshot"))
hl.bind("Print", hl.dsp.exec_cmd("flameshot gui"))
hl.bind(Mod .. " + SHIFT + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | tee >(wl-copy --type image/png) | satty --filename - --fullscreen --output-filename ~/Pictures/ssss/screenshot-%Y%m%d-%H%M%S.png]]))


-- Click outside wofi to close it
--hl.bind("mouse:272", hl.dsp.exec_cmd("~/.local/bin/wofi-click-close.sh"))


hl.bind(Mod .. " + SHIFT + L", hl.dsp.exec_cmd("~/.local/bin/screensaver.sh"))
hl.bind(Mod .. " + SHIFT + Z", hl.dsp.exec_cmd("~/.local/bin/screensaver.sh"))
hl.bind(Mod .. " + SHIFT + Z", hl.dsp.exec_cmd("~/.local/bin/launch-screensaver.sh"))
hl.bind(Mod .. " + SHIFT + G", hl.dsp.exec_cmd("~/.config/hypr/gaps-toggle.sh"))
