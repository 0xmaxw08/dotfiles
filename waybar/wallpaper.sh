#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/walls"
STATE_FILE="/tmp/current_wallpaper"
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

echo "$NEXT_WALL" > "$STATE_FILE"

# Regenerate waybar theme to match new wallpaper
matugen image "$NEXT_WALL" --source-color-index 0 --mode dark --contrast 1 --config ~/.config/matugen/config.toml >/dev/null 2>&1
