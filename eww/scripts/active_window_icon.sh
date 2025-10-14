#!/bin/bash
app_class=$(hyprctl activewindow -j | jq -r '.class')
icon_base="/home/duck/.local/share/icons/WhiteSur-dark/apps/scalable"

if [ -f "${icon_base}/${app_class}.svg" ]; then
  echo "${icon_base}/${app_class}.svg"
  exit 0
fi

app_lower=$(echo "$app_class" | tr '[:upper:]' '[:lower:]')
if [ -f "${icon_base}/${app_lower}.svg" ]; then
  echo "${icon_base}/${app_lower}.svg"
  exit 0
fi

case "$app_class" in
"firefox" | "Firefox")
  echo "${icon_base}/firefox.svg"
  ;;
"code" | "Code" | "VSCode" | "code-oss")
  echo "${icon_base}/visual-studio-code.svg"
  ;;
"discord" | "Discord")
  echo "${icon_base}/discord.svg"
  ;;
*)
  echo "${icon_base}/preferences-system-linux.svg"
  ;;
esac
