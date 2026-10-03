#!/usr/bin/env bash
bluetoothctl --monitor | while read -r line; do
    if [[ "$line" == *"Device"*"Connected: yes"* ]]; then
        mac=$(echo "$line" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
        name=$(bluetoothctl info "$mac" | awk -F': ' '/Name/{print $2}')
        notify-send "Bluetooth connected" "${name:-$mac}"
    elif [[ "$line" == *"Device"*"Connected: no"* ]]; then
        mac=$(echo "$line" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
        name=$(bluetoothctl info "$mac" | awk -F': ' '/Name/{print $2}')
        notify-send "Bluetooth disconnected" "${name:-$mac}"
    fi
done
