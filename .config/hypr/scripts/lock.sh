#!/usr/bin/env bash
conf="$HOME/.config/hypr/hyprlock.conf"
msg="$("$HOME/.config/hypr/scripts/lock-greeting.sh")"
sed -i --follow-symlinks "s|^\(\s*\)placeholder_text =.*|\1placeholder_text = <i>${msg//|/\\|}</i>|" "$conf"
pgrep -x hyprlock >/dev/null || exec hyprlock
