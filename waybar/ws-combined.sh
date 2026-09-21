#!/usr/bin/env bash

ACTIVE=$(hyprctl activeworkspace -j | grep -o '"id": [0-9]*' | grep -o '[0-9]*$')
MAX=5
if (( ACTIVE > MAX )); then
    MAX=$ACTIVE
fi

TEXT=""
for i in $(seq 1 "$MAX"); do
    if [[ "$i" == "$ACTIVE" ]]; then
        TEXT="$TEXT<span foreground='#0a0a0a' background='#e8e8e8' weight='bold'> $i </span> "
    else
        TEXT="$TEXT<span foreground='#4a4a4a'> $i </span> "
    fi
done

echo "{\"text\": \"$TEXT\"}"
