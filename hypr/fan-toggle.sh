#!/usr/bin/env bash

STATE_FILE="/tmp/fan_mode"
HWMON_DIR=$(find /sys/devices/platform/hp-wmi/hwmon -mindepth 1 -maxdepth 1 -type d -name "hwmon*" | head -1)
PWM_ENABLE="$HWMON_DIR/pwm1_enable"
PWM1_VALUE="$HWMON_DIR/pwm1"
PWM2_VALUE="$HWMON_DIR/pwm2"

CURRENT="curve"
if [[ -f "$STATE_FILE" ]]; then
    CURRENT=$(cat "$STATE_FILE")
fi

if [[ "$CURRENT" == "max" ]]; then
    MODE="curve"
    sudo /home/max/.local/bin/omen-fan-control fan-control --mode curve --no-save
    sleep 1
    sudo systemctl restart omen-fan-control.service
else
    MODE="max"
    sudo /home/max/.local/bin/omen-fan-control fan-control --mode max --no-save
    sleep 1
    echo 1 | sudo tee "$PWM_ENABLE" > /dev/null
    echo 255 | sudo tee "$PWM1_VALUE" > /dev/null
    echo 255 | sudo tee "$PWM2_VALUE" > /dev/null
fi

echo "$MODE" > "$STATE_FILE"
notify-send "Fan Mode" "Switched to $MODE"
