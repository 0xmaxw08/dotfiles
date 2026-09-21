#!/usr/bin/env bash

WS=$1
ACTIVE=$(hyprctl activeworkspace -j | grep -o '"id": [0-9]*' | grep -o '[0-9]*$')

if [[ "$ACTIVE" == "$WS" ]]; then
    echo "{\"text\": \"$WS\", \"class\": \"active\"}"
else
    echo "{\"text\": \"$WS\", \"class\": \"inactive\"}"
fi
