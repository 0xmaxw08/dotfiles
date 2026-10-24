#!/usr/bin/env bash
f="$HOME/.config/hypr/lockscreen/messages.txt"
last="${XDG_RUNTIME_DIR:-/tmp}/lock-greeting.last"
[ -f "$f" ] || { echo "welcome back, ${USER,,}"; exit 0; }
prev=$(cat "$last" 2>/dev/null)
line=$(grep -vxF "$prev" "$f" | shuf -n 1)
[ -n "$line" ] || line=$(shuf -n 1 "$f")
printf '%s' "$line" > "$last"
echo "$line" | sed "s/USER/$USER/g" | tr '[:upper:]' '[:lower:]'
