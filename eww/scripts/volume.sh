#!/bin/bash

get_volume() {
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n1)
    LVL=$(echo "$VOL" | tr -d '%')

    printf '{"display": "%s", "level": %d}\n' "$VOL" "$LVL"
}

get_volume

pactl subscribe | grep --line-buffered "sink" | while read -r _; do
    get_volume
done
