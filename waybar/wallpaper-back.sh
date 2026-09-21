#!/usr/bin/env bash

STATE_FILE="/tmp/current_wallpaper"
HISTORY_FILE="/tmp/wallpaper_history"
POS="$(hyprctl cursorpos | tr -d ' ')"

if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
    notify-send "Wallpaper" "No history to go back to"
    exit 1
fi

PREV_WALL=$(tail -n 1 "$HISTORY_FILE")
sed -i '$ d' "$HISTORY_FILE"

awww img "$PREV_WALL" \
  --transition-type grow \
  --transition-pos "$POS" \
  --transition-step 4 \
  --transition-fps 144 \
  --invert-y

echo "$PREV_WALL" > "$STATE_FILE"
notify-send "Wallpaper" "Went back to previous"
