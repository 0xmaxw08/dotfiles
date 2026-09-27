#!/usr/bin/env bash

REPO_UPDATES=$(checkupdates 2>/dev/null)
REPO_COUNT=$(echo -n "$REPO_UPDATES" | grep -c '^')

AUR_UPDATES=$(yay -Qua 2>/dev/null)
AUR_COUNT=$(echo -n "$AUR_UPDATES" | grep -c '^')

TOTAL=$((REPO_COUNT + AUR_COUNT))

if [[ "$TOTAL" -eq 0 ]]; then
    echo "{\"text\": \"\", \"class\": \"clean\", \"tooltip\": \"you are up to date max!\"}"
    exit 0
fi

TOOLTIP=""
if [[ "$REPO_COUNT" -gt 0 ]]; then
    TOOLTIP="Official (${REPO_COUNT}):\n$(echo "$REPO_UPDATES" | awk '{print "  " $1 "  " $2 " \u2192 " $4}')"
fi
if [[ "$AUR_COUNT" -gt 0 ]]; then
    if [[ -n "$TOOLTIP" ]]; then
        TOOLTIP="${TOOLTIP}\n\n"
    fi
    TOOLTIP="${TOOLTIP}AUR (${AUR_COUNT}):\n$(echo "$AUR_UPDATES" | awk '{print "  " $1 "  " $2 " \u2192 " $4}')"
fi

echo "{\"text\": \"\uf021 ${TOTAL}\", \"class\": \"pending\", \"tooltip\": \"$TOOLTIP\"}"
