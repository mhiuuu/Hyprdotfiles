#!/bin/bash

SSID="$1"
PASSWORD="$2"
SECURITY="$3"   
KNOWN="$4"     

eww update ACTIVE_INPUT="$SSID"

function clear_password() {
    nmcli connection modify "$SSID" 802-11-wireless-security.psk "" 2>/dev/null
}

function delete_connection() {
    nmcli connection delete id "$SSID" 2>/dev/null
}

function password_prompt() {
    eww open wifi_password
}

function connect() {
    if [ -z "$PASSWORD" ]; then
        password_prompt
        exit 1
    fi

    nmcli dev wifi connect "$SSID" password "$PASSWORD"
    if [ $? -eq 0 ]; then
        eww update ACTIVE_INPUT=""
        eww close wifi_password
        notify-send "Connected to $SSID"
        exit 0
    else
        notify-send "Wrong password"
        if [ "$KNOWN" = "true" ]; then
            # If it's a known connection → only clear password
            clear_password
        else
            # If it's a new connection → remove whole profile
            delete_connection
        fi
        password_prompt
        exit 1
    fi
}

if [ "$KNOWN" = "true" ]; then
    nmcli connection up id "$SSID" 2>/dev/null
    if [ $? -eq 0 ]; then
        eww update ACTIVE_INPUT=""
        exit 0
    else
        # Known but failed → clear password only
        clear_password
        password_prompt
        exit 1
    fi
else
    if [ "$SECURITY" = "false" ]; then
        nmcli dev wifi connect "$SSID"
        if [ $? -eq 0 ]; then
            notify-send "Public WiFi" "Connected to $SSID. Consider opening dashboard."
            eww update ACTIVE_INPUT=""
            exit 0
        else
            notify-send "Public WiFi" "Failed to connect to $SSID"
            exit 1
        fi
    else
        connect
    fi
fi
