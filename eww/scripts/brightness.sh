#!/bin/bash

get_brightness() {
    current=$(brightnessctl get)
    max=$(brightnessctl max)

    percent=$(( current * 100 / max ))

    printf '{"display": "%d%%", "level": %d}\n' "$percent" "$percent"
}

get_brightness

udevadm monitor --udev --subsystem-match=backlight \
  | while read -r _; do
        get_brightness
    done
