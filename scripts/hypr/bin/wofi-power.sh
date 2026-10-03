#!/usr/bin/env bash

OPTIONS="Lock\nScreensaver\nLog Out\nReboot\nShutdown"

SELECTION=$(echo -e "$OPTIONS" | wofi --dmenu --width 300 --height 280 --prompt "goodbye, max <3" --cache-file /dev/null)

case "$SELECTION" in
    *"Lock")
        hyprlock || swaylock
        ;;
    *"Screensaver")
        ~/.local/bin/launch-screensaver.sh
        ;;
    *"Log Out")
        loginctl terminate-session self || hyprctl dispatch exit
        ;;
    *"Reboot")
        systemctl reboot
        ;;
    *"Shutdown")
        systemctl poweroff
        ;;
esac
