#!/usr/bin/env bash

# Kill any existing hyprlock instance check
if pgrep -x hyprlock >/dev/null 2>&1; then
    exit 0
fi

# Launch hyprlock through Hyprland
hyprctl dispatch exec hyprlock
