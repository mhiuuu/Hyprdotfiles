#!/bin/bash

case "$1" in
  wifi)
    eww close bluetooth
    eww close control-center
    eww open wifi
    eww update SHOW_CONTROL_CENTER=false SHOW_WIFI=true SHOW_BLUETOOTH=false
    ;;

  bluetooth)
    eww close wifi
    eww close control-center
    eww open bluetooth
    eww update SHOW_CONTROL_CENTER=false SHOW_WIFI=false SHOW_BLUETOOTH=true
    ;;

  controlcenter)
    eww close wifi
    eww close bluetooth
    eww open control-center
    eww update SHOW_CONTROL_CENTER=true SHOW_WIFI=false SHOW_BLUETOOTH=false
    ;;

  *)
    exit 1
    ;;
esac
