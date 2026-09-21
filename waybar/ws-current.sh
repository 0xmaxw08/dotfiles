#!/usr/bin/env bash
ACTIVE=$(hyprctl activeworkspace -j | grep -o '"id": [0-9]*' | grep -o '[0-9]*$')
if [[ "$ACTIVE" -gt 5 ]]; then
    echo "{\"text\": \"$ACTIVE\"}"
else
    echo "{\"text\": \"\"}"
fi
