#!/bin/bash

function dunst_show_history() {
    hist_size=$(dunstctl history | jq '.data[0] | length')
    for i in `seq $hist_size`; do
        dunstctl history-pop
    done
}

if [[ $(dunstctl is-paused) == true ]]; then
    eww update DND=false
    dunstctl set-paused toggle
    dunst_show_history
else 
    eww update DND=true
    dunstctl set-paused toggle
fi
