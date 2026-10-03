#!/usr/bin/env bash
while true; do
    sleep 1800
    notify-send -t 10000 "suki" "$(~/.local/bin/greeting.sh)"
done
