#!/usr/bin/env bash
f="$HOME/.config/hypr/lockscreen/messages.txt"
[ -f "$f" ] || { echo "welcome back, ${USER,,}"; exit 0; }
shuf -n 1 "$f" | sed "s/USER/$USER/g" | tr '[:upper:]' '[:lower:]'
