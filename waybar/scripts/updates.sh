#!/usr/bin/env bash

css_class="updates"

if ! updates_arch=$(checkupdates 2> /dev/null | wc -l); then
    updates_arch=0
fi

if ! updates_aur=$(yay -Qua 2> /dev/null | wc -l); then
    updates_aur=0
fi 

updates=$(($updates_arch + $updates_aur))

printf '{"text": "%s", "alt": "%s", "tooltip": "%s Updates", "class": "%s"}' "$updates" "$updates" "$updates" "$css_class"
