#!/usr/bin/env bash
FAN1=$(cat /sys/devices/platform/hp-wmi/hwmon/hwmon5/fan1_input 2>/dev/null)
FAN2=$(cat /sys/devices/platform/hp-wmi/hwmon/hwmon5/fan2_input 2>/dev/null)
echo "Fan 1: ${FAN1:-N/A} RPM\nFan 2: ${FAN2:-N/A} RPM"
