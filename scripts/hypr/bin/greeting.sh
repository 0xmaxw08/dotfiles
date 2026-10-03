#!/usr/bin/env bash

USER_NAME="max"
HOUR=$(date +%H)
DOW=$(date +%A)
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
TEMP_C=$(( ${TEMP:-0} / 1000 ))
UPTIME_MIN=$(awk '{print int($1/60)}' /proc/uptime)
UPDATES=$(checkupdates 2>/dev/null | wc -l)
FAN_MODE=$(cat /tmp/fan_mode 2>/dev/null || echo "curve")
BATTERY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
CHARGING=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
CPU_LOAD=$(awk '{print int($1)}' /proc/loadavg)
MEM_PCT=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

TRACK=$(playerctl metadata title 2>/dev/null)
ARTIST=$(playerctl metadata artist 2>/dev/null)
PLAY_STATUS=$(playerctl status 2>/dev/null)

POOL=()

# Time-of-day base greetings
if (( HOUR >= 5 && HOUR < 12 )); then
    POOL+=("Good morning, $USER_NAME." "Morning, $USER_NAME." "Up early — morning, $USER_NAME." "Rise and grind, $USER_NAME." "It's $DOW morning, $USER_NAME.")
elif (( HOUR >= 12 && HOUR < 17 )); then
    POOL+=("Good afternoon, $USER_NAME." "Hey $USER_NAME." "Halfway through $DOW, $USER_NAME." "Afternoon check-in, $USER_NAME.")
elif (( HOUR >= 17 && HOUR < 22 )); then
    POOL+=("Good evening, $USER_NAME." "Evening, $USER_NAME." "$DOW evening — welcome back." "Winding down, $USER_NAME?")
else
    POOL+=("Still up, $USER_NAME?" "Late one tonight." "It's past midnight, $USER_NAME." "Burning the midnight oil, $USER_NAME.")
fi

# Thermal
if (( TEMP_C > 80 )); then
    POOL+=("Running hot — ${TEMP_C}°C right now." "${TEMP_C}°C. Fans earning their keep.")
elif (( TEMP_C > 0 && TEMP_C < 35 )); then
    POOL+=("Nice and cool, ${TEMP_C}°C.")
fi

# Updates
if (( UPDATES > 15 )); then
    POOL+=("$UPDATES updates piling up." "You're $UPDATES packages behind.")
elif (( UPDATES > 0 )); then
    POOL+=("$UPDATES updates whenever you're ready.")
fi

# Fan state
if [[ "$FAN_MODE" == "max" ]]; then
    POOL+=("Fans at max — heavy load ahead?")
fi

# Battery
if [[ -n "$BATTERY" ]]; then
    if [[ "$CHARGING" != "Charging" ]] && (( BATTERY < 20 )); then
        POOL+=("Battery's at ${BATTERY}% — might want to plug in." "${BATTERY}% left, running low.")
    elif [[ "$CHARGING" == "Charging" ]] && (( BATTERY < 50 )); then
        POOL+=("Charging up, ${BATTERY}% so far.")
    fi
fi

# Uptime
if (( UPTIME_MIN > 480 )); then
    POOL+=("$((UPTIME_MIN / 60))h uptime and counting." "Been running for $((UPTIME_MIN / 60)) hours straight.")
fi

# CPU load
if (( CPU_LOAD >= 6 )); then
    POOL+=("I'm under real load right now.")
fi

# Memory
if (( MEM_PCT > 80 )); then
    POOL+=("Memory's at ${MEM_PCT}% — getting tight.")
fi

if [[ -n "$TRACK" ]]; then
    if [[ "$PLAY_STATUS" == "Playing" ]]; then
        POOL+=("Listening to $TRACK" "$TRACK by $ARTIST, nice choice." "Currently playing: $TRACK.")
    elif [[ "$PLAY_STATUS" == "Paused" ]]; then
        POOL+=("$TRACK is paused — pick it back up?" "Left $TRACK by $ARTIST on pause.")
    fi
fi
# Romantic
if [[ -n "$TRACK" ]]; then
    POOL+=("If this were a playlist for you, $TRACK would be track one.")
fi
POOL+=("Every uptime is better with you around.")

# Romantic
POOL+=("Wish you were here to see this." "Thinking of you, as usual." "Some days I just want to hear your voice.")
if [[ -n "$TRACK" ]]; then
    POOL+=("This song reminds me of you." "$TRACK is playing — feels like something you'd love.")
fi
if (( UPTIME_MIN > 480 )); then
    POOL+=("Long day. Wish you were next to me right now.")
fi

RANDOM_INDEX=$(( RANDOM % ${#POOL[@]} ))
echo "${POOL[$RANDOM_INDEX]}"
