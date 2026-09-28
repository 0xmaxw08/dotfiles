#!/usr/bin/env bash
CONFIG_DIR="$HOME/.config/waybar"
STATE_FILE="/tmp/waybar_mode"
MODE="floating"
[[ -f "$STATE_FILE" ]] && MODE="$(cat "$STATE_FILE")"
pkill waybar
sleep 0.3
waybar -c "$CONFIG_DIR/config-$MODE.jsonc" -s "$CONFIG_DIR/style-$MODE.css" 200>&- &
disown
