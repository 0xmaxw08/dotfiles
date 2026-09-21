-- Applications
hl.window_rule({
    name  = "spotify-workspace",
    match = { class = "^(Spotify)$" },
    workspace = "4 silent",
})

hl.window_rule({
    name  = "helium-workspace",
    match = { class = "^(helium)$" },
    workspace = "2",
})

hl.window_rule({
    name  = "discord-workspace",
    match = { class = "^(discord)$" },
    workspace = "3 silent",
})

hl.window_rule({
    name  = "telegram-workspace",
    match = { class = "^(TelegramDesktop|org.telegram.desktop)$" },
    workspace = "3 silent",
})

hl.window_rule({
    name  = "whatsapp-workspace",
    match = { class = "^(WhatsApp|whatsie|whatsapp-for-linux)$" },
    workspace = "3 silent",
})

hl.window_rule({
    name  = "signal-workspace",
    match = { class = "^(Signal)$" },
    workspace = "3 silent",
})

hl.window_rule({
    name  = "slack-workspace",
    match = { class = "^(Slack|slack)$" },
    workspace = "3 silent",
})

hl.window_rule({
    name  = "element-workspace",
    match = { class = "^(Element|im.riot.Riot)$" },
    workspace = "3 silent",
})

hl.layer_rule({
    name  = "waybar-blur-fix",
    match = { namespace = "waybar" },
    blur  = false,
    xray  = true,
})

hl.config({
    render = {
        direct_scanout = false,
    },
})

hl.on("workspace.active", function(event_data)
    hl.exec_cmd("pkill -RTMIN+8 waybar")
end)

hl.layer_rule({
    name  = "wofi-blur-fix",
    match = { namespace = "wofi" },
    blur  = false,
    xray  = true,
})


hl.window_rule({
    name  = "screensaver-fullscreen",
    match = { class = "^(org.hypr.screensaver)$" },
    workspace = "special:screensaver",
})

hl.window_rule({
    name  = "screensaver-fullscreen",
    match = { class = "^(org.hypr.screensaver)$" },
    float = true,
})
