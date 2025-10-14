#!/bin/bash

previous_output=""

print_status() {
  ssid="Connecting..."
  signal="null"

  # Get Wi-Fi SSID + Signal (if any active WiFi)
  wifi_info=$(nmcli -t -f IN-USE,SSID,SIGNAL device wifi | grep '^\*')
  if [[ -n "$wifi_info" ]]; then
    ssid=$(echo "$wifi_info" | awk -F: '{print $2}')
    signal=$(echo "$wifi_info" | awk -F: '{print $3}')
  fi

  current_output=$(printf '{"ssid":"%s","signal":%s}' "$ssid" "$signal")

  if [[ "$current_output" != "$previous_output" ]]; then
    echo "$current_output"
    previous_output="$current_output"
  fi
}

print_status

nmcli monitor | while read -r _; do
  print_status
done
