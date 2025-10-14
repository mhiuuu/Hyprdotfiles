#!/bin/bash

killall eww 2>/dev/null

eww daemon
if [[ $(nmcli radio wifi) == "enabled" ]]; then
    eww update wireless=true
else 
    eww update wireless=false
fi

if [[ $(dunstctl is-paused) ]]; then
    eww update DND=true
else 
    eww update DND=false
fi

eww open bar
