#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/walls"
STATE_FILE="/tmp/current_wallpaper"
HISTORY_FILE="/tmp/wallpaper_history"
LOCK_FILE="/tmp/wallpaper_switch.lock"
LOG_FILE="/tmp/wallpaper_switch.log"
MAX_HISTORY=20

exec 200>"$LOCK_FILE"
flock -n 200 || { notify-send "Wallpaper" "Already switching, ignoring extra press"; exit 0; }

POS="$(hyprctl cursorpos | tr -d ' ')"

mapfile -t WALLPAPERS < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort)

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
   notify-send "Wallpaper" "No images found in $WALL_DIR"
   exit 1
fi

CURRENT=""
if [[ -f "$STATE_FILE" ]]; then
   CURRENT=$(cat "$STATE_FILE")
fi

NEXT_WALL="$CURRENT"
if [[ ${#WALLPAPERS[@]} -gt 1 ]]; then
   while [[ "$NEXT_WALL" == "$CURRENT" ]]; do
       RANDOM_INDEX=$(( RANDOM % ${#WALLPAPERS[@]} ))
       NEXT_WALL="${WALLPAPERS[$RANDOM_INDEX]}"
   done
else
   NEXT_WALL="${WALLPAPERS[0]}"
fi

awww img "$NEXT_WALL" \
 --transition-type grow \
 --transition-pos "$POS" \
 --transition-step 4 \
 --transition-fps 144 \
 --invert-y

if [[ -n "$CURRENT" ]]; then
   echo "$CURRENT" >> "$HISTORY_FILE"
   tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
fi

echo "$NEXT_WALL" > "$STATE_FILE"

if ! matugen image "$NEXT_WALL" --source-color-index 0 --mode dark --contrast 1 --config ~/.config/matugen/config.toml >>"$LOG_FILE" 2>&1; then
    notify-send "Wallpaper" "matugen failed, check $LOG_FILE"
fi

~/.config/matugen/apply.sh >>"$LOG_FILE" 2>&1
