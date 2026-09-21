#!/usr/bin/env bash

STATE_FILE="/tmp/gaps_mode"

CURRENT="normal"
if [[ -f "$STATE_FILE" ]]; then
    CURRENT=$(cat "$STATE_FILE")
fi

if [[ "$CURRENT" == "zero" ]]; then
    MODE="normal"
    hyprctl eval "hl.config({ general = { gaps_in = 10, gaps_out = 15 } })"
else
    MODE="zero"
    hyprctl eval "hl.config({ general = { gaps_in = 0, gaps_out = 0 } })"
fi

echo "$MODE" > "$STATE_FILE"
