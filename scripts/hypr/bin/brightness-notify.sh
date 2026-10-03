#!/usr/bin/env bash

DIRECTION="$1"
brightnessctl -s set "1%${DIRECTION}" >/dev/null 2>&1

CURRENT=$(brightnessctl get)
MAX=$(brightnessctl max)
PERCENT=$(( CURRENT * 100 / MAX ))

# Build a simple bar
FILLED=$(( PERCENT / 10 ))
EMPTY=$(( 10 - FILLED ))
BAR=$(printf '%*s' "$FILLED" | tr ' ' '█')$(printf '%*s' "$EMPTY" | tr ' ' '░')

notify-send -h int:value:"$PERCENT" -h string:x-canonical-private-synchronous:brightness \
    -t 1200 "󰃟 Brightness" "${BAR}  ${PERCENT}%"
