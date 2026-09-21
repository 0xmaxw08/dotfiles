#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/waybar"
STATE_FILE="/tmp/waybar_mode"

if pgrep -x waybar > /dev/null; then
    if [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "docked" ]]; then
        MODE="floating"
    else
        MODE="docked"
    fi
    pkill waybar
    sleep 0.3
    waybar -c "$CONFIG_DIR/config-$MODE.jsonc" -s "$CONFIG_DIR/style-$MODE.css" &
    echo "$MODE" > "$STATE_FILE"
else
    MODE="floating"
    waybar -c "$CONFIG_DIR/config-$MODE.jsonc" -s "$CONFIG_DIR/style-$MODE.css" &
    echo "$MODE" > "$STATE_FILE"
fi
