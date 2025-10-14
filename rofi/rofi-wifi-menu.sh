#!/bin/zsh
# A rofi-based menu interface for WiFi control using nmcli

# --- Functions --- #
get_match() {
    selection=$(echo -e "$1" | rofi -dmenu -p "$2" -config ~/.dotfiles/rofi/theme.rasi)
    [[ -z "$selection" ]] && exit 1

    does_match_=$(echo -e "$1" | grep "$selection")
    [[ -n "$1" ]] && [[ -z "$does_match_" ]] && exit 1

    echo "$selection"
}

# --- Constants --- #
toggle_entry="WiFi"
create_option="Manual connection"

# --- Check WiFi state --- #
state=$(nmcli -fields WIFI g)
enable_test=$(echo "$state" | grep "enabled")

if [[ -z "$enable_test" ]]; then
    toggle="$toggle_entry on"
    selection=$(get_match "Yes\nNo" "Enable WiFi")
    if [[ "$selection" = "Yes" ]]; then
        nmcli radio wifi on
    fi
    exit 1
else
    toggle="$toggle_entry off"
fi

# --- Gather WiFi info --- #
fields="SSID,BARS,SECURITY"
lines_full=$(nmcli --terse --fields $fields dev wifi)
lines=$(echo -e "$lines_full" | awk -F ":" '{print $1"  "$2}')

cons=$(nmcli con show)
current=$(iwgetid -r)
ssid_field=$(echo -e "$fields" | awk 'BEGIN {FS=","} {for (i=1; i<=NF; ++i) if ($i ~ "SSID") print i}')

# --- Main selection --- #
selection=$(get_match "$toggle\n$lines\n$create_option" "WiFi")
selected_ssid=$(echo "$selection" | sed 's/\s\{2,\}/|/g' | awk -F "|" "{print \$$ssid_field}")

# --- Handle manual connection --- #
if [[ "$selected_ssid" = "$create_option" ]]; then
    manual_ssid=$(echo "Enter the SSID of the network." | rofi -dmenu -p "SSID" -config ~/.dotfiles/rofi/config.rasi)
    [[ -z "$manual_ssid" ]] && exit 1

    # Check if connection already exists
    matches00=$(echo -e "$cons" | sed 's/\s\{2,\}/|/g' | awk -F "|" "/$manual_ssid/{print \$1}")

    if [[ -n "$matches00" ]]; then
        n_matches00=$(echo -e "$matches00" | wc -l)

        if [[ "$n_matches00" -eq 1 ]]; then
            nmcli con up "$manual_ssid"
        else
            chosen_cons00=$(get_match "$matches00" "Which")
            nmcli con up "$chosen_cons00"
        fi
    else
        manual_password=$(echo "Enter the Password of the network (or leave blank)." \
            | rofi -dmenu -p "Password" -config ~/.dotfiles/rofi/config.rasi)

        if [[ -z "$manual_password" ]]; then
            nmcli dev wifi con "$manual_ssid"
        else
            nmcli dev wifi con "$manual_ssid" password "$manual_password"
        fi
    fi

# --- Toggle WiFi --- #
elif [[ "$selected_ssid" = "$toggle_entry on" ]]; then
    nmcli radio wifi on

elif [[ "$selected_ssid" = "$toggle_entry off" ]]; then
    nmcli radio wifi off

# --- Existing connection --- #
elif [[ -n "$selection" ]]; then
    matches=$(echo -e "$cons" | sed 's/\s\{2,\}/|/g' | awk -F "|" "/$selected_ssid/{print \$1}")

    if [[ -n "$matches" ]]; then
        n_matches=$(echo -e "$matches" | wc -l)

        if [[ "$n_matches" -eq 1 ]]; then
            nmcli con up "$selected_ssid"
        else
            chosen_cons=$(get_match "$matches" "Which")
            nmcli con up "$chosen_cons"
        fi

    else
        # --- New connection --- #
        wlan_=$(nmcli dev | grep wifi | sed 's/ \{2,\}/|/g' | cut -d'|' -f1)
        sec0=$(echo -e "$lines_full" | grep "$selected_ssid" | awk '/802\.1X/')

        # 802.1x security
        if [[ -n "$sec0" ]]; then
            user_name=$(echo "Enter identity." | rofi -dmenu -p "Identity" -config ~/.dotfiles/rofi/config.rasi)
            [[ -z "$user_name" ]] && exit 1

            password0=$(echo "Enter password of your identity (or leave empty)." \
                | rofi -dmenu -p "Password" -config ~/.dotfiles/rofi/config.rasi)

            n_matches_=$(echo -e "$wlan_" | wc -l)
            if [[ "$n_matches_" -gt 1 ]]; then
                wlan_=$(get_match "$wlan_" "ifname")
            fi

            nmcli con add type wifi con-name "$selected_ssid" ifname "$wlan_" ssid "$selected_ssid" -- \
                wifi-sec.key-mgmt wpa-eap 802-1x.eap ttls \
                802-1x.phase2-auth mschapv2 802-1x.identity "$user_name" 802-1x.password "$password0"

            nmcli con up "$selected_ssid"

        # WPA / WEP
        else
            sec=$(echo -e "$lines_full" | grep "$selected_ssid" | awk '/(WPA|WEP)/')

            if [[ -n "$sec" ]]; then
                password_=$(echo "Enter password of the network (or leave blank)." \
                    | rofi -dmenu -p "Password" -config ~/.dotfiles/rofi/config.rasi)
            fi

            nmcli dev wifi con "$selected_ssid" password "$password_"
        fi
    fi
fi
