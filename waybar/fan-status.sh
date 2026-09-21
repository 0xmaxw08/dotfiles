#!/usr/bin/env bash

STATE_FILE="/tmp/fan_mode"
MODE="curve"
if [[ -f "$STATE_FILE" ]]; then
    MODE=$(cat "$STATE_FILE")
fi

FAN1=$(cat /sys/devices/platform/hp-wmi/hwmon/hwmon5/fan1_input 2>/dev/null)
FAN2=$(cat /sys/devices/platform/hp-wmi/hwmon/hwmon5/fan2_input 2>/dev/null)
TOOLTIP="Fan 1: ${FAN1:-N/A} RPM\nFan 2: ${FAN2:-N/A} RPM"

if [[ "$MODE" == "max" ]]; then
    echo "{\"text\": \"FAN MAX\", \"class\": \"max\", \"tooltip\": \"$TOOLTIP\"}"
else
    echo "{\"text\": \"FAN CURVE\", \"class\": \"curve\", \"tooltip\": \"$TOOLTIP\"}"
fi
