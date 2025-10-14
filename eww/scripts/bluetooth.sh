#!/bin/bash

bluetoothctl --timeout 5 scan on > /dev/null
DEVICES=$(bluetoothctl devices)

JSON=$(jq -n '[]')

get_type() {
    case "$1" in
        audio-headset)  echo "Headset" ;;
        audio-card)     echo "Audio" ;;
        input-keyboard) echo "Keyboard" ;;
        input-mouse)    echo "Mouse" ;;
        input-gaming)   echo "Controller" ;;
        phone)          echo "Phone" ;;
        computer)       echo "Computer" ;;
        *)              echo "Misc" ;;
    esac
}

while read -r _ mac name_rest; do
    [ -z "$mac" ] && continue

    info=$(bluetoothctl info "$mac")
    icon=$(awk -F': ' '/Icon/ {print $2}' <<< "$info")
    type=$(get_type "$icon")

    [[ "$type" == "Misc" ]] && continue

    if grep -q "Paired: yes" <<< "$info"; then
        known=true
    else
        known=false
    fi

    if grep -q "Connected: yes" <<< "$info"; then
        current=true
    else
        current=false
    fi

    JSON=$(jq \
        --arg mac "$mac" \
        --arg name "$name_rest" \
        --arg type "$type" \
        --argjson known "$known" \
        --argjson current "$current" \
        '. + [{mac:$mac, name:$name, type:$type, known:$known, current:$current}]' \
        <<< "$JSON")
done <<< "$DEVICES"

echo "$JSON" | jq 'sort_by(.current, .known, .name) | reverse'
