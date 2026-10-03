#!/usr/bin/env bash
ACTIVE=$(grep -P '^\s*active_border' ~/.config/hypr/colors.conf | grep -oP '(?<=")[a-fA-F0-9]{6}(?=")')
INACTIVE=$(grep -P '^\s*inactive_border' ~/.config/hypr/colors.conf | grep -oP '(?<=")[a-fA-F0-9]{6}(?=")')

CMD="hl.config({ general = { col = { active_border = \"rgb(${ACTIVE})\", inactive_border = \"rgb(${INACTIVE})\" } } })"
hyprctl eval "$CMD"
