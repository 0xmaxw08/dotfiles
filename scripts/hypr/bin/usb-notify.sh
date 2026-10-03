#!/usr/bin/env bash
# Called by udev as root. Relays a notification into the user's session.
USER_NAME="max"
UID_NUM=$(id -u "$USER_NAME")
ACTION="$1"
LABEL="${ID_MODEL:-${ID_FS_LABEL:-Unknown device}}"

case "$ACTION" in
    add)    TITLE="Device connected" ;;
    remove) TITLE="Device disconnected" ;;
    *)      exit 0 ;;
esac

sudo -u "$USER_NAME" \
    XDG_RUNTIME_DIR="/run/user/$UID_NUM" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID_NUM/bus" \
    notify-send "$TITLE" "$LABEL"
