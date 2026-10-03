#!/usr/bin/env bash

# Exit if wofi isn't running
pgrep -x wofi > /dev/null || exit 0

# Get cursor position
CURSOR=$(hyprctl cursorpos -j)
CX=$(echo "$CURSOR" | jq -r '.x')
CY=$(echo "$CURSOR" | jq -r '.y')

# Get wofi's layer rectangle(s)
LAYERS=$(hyprctl layers -j)

INSIDE=$(echo "$LAYERS" | jq -r --argjson cx "$CX" --argjson cy "$CY" '
  [.[] | .levels[]? | .[]? | select(.namespace == "wofi") |
    select($cx >= .x and $cx <= (.x + .w) and $cy >= .y and $cy <= (.y + .h))
  ] | length
')

if [[ "$INSIDE" -eq 0 ]]; then
    pkill wofi
fi
