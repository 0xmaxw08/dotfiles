#!/usr/bin/env bash

if hyprctl clients -j | jq -e '.[] | select(.class == "org.hypr.screensaver")' >/dev/null 2>&1; then
    exit 0
fi

kitty \
    --class "org.hypr.screensaver" \
    --title "screensaver" \
    -e ~/.local/bin/screensaver.sh &

sleep 0.3

hyprctl dispatch "hl.dsp.window.fullscreen({ action = 'toggle' })"
