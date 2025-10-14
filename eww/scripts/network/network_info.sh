#!/bin/bash

LIST=$(nmcli --fields SSID,SECURITY,BARS device wifi list \
    | sed '/^--/d' | sed 1d \
    | sed -E "s/WPA*.?\S/~true~/g" \
    | sed "s/~true~ ~true~/~true~/g;s/802\.1X//g;s/--/~false~/g" \
    | sed 's/  *~/~/g;s/~  */~/g;s/_/ /g')

KNOWCON=$(nmcli -t -f NAME,TYPE connection show | grep "wireless" | cut -d: -f1)
CURRCON=$(nmcli -t -f "ACTIVE,SSID" dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

JSON=$(jq -n '[]')

while IFS="~" read -r ssid security bars; do
    [ -z "$ssid" ] && continue

    if grep -Fxq "$ssid" <<< "$KNOWCON"; then
        known=true
    else
        known=false
    fi

    if [ "$ssid" = "$CURRCON" ]; then
        current=true
    else
        current=false
    fi

    strength=$(echo -n "$bars" | tr -d ' ' | wc -m)

    JSON=$(jq \
        --arg ssid "$ssid" \
        --argjson security "$security" \
        --argjson known "$known" \
        --argjson current "$current" \
        --argjson strength "$strength" \
        '. + [{ssid:$ssid, security:$security, known:$known, current:$current, strength:$strength}]' \
        <<< "$JSON")
done <<< "$LIST"


echo "$JSON" | jq 'sort_by(.current, .known, .strength) | reverse'
