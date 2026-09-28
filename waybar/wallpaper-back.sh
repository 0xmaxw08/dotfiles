#!/usr/bin/env bash

STATE_FILE="/tmp/current_wallpaper"
HISTORY_FILE="/tmp/wallpaper_history"
LOCK_FILE="/tmp/wallpaper_switch.lock"
LOG_FILE="/tmp/wallpaper_switch.log"

exec 200>"$LOCK_FILE"
flock -n 200 || { notify-send "Wallpaper" "Already switching, ignoring extra press"; exit 0; }

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

if ! matugen image "$PREV_WALL" --source-color-index 0 --mode dark --contrast 1 --config ~/.config/matugen/config.toml >>"$LOG_FILE" 2>&1; then
    notify-send "Wallpaper" "matugen failed, check $LOG_FILE"
fi

~/.config/matugen/apply.sh >>"$LOG_FILE" 2>&1
notify-send "Wallpaper" "Went back to previous"
