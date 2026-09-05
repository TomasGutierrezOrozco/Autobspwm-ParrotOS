#!/usr/bin/env bash

# OSD notification script for volume and brightness with in-place replacement
VOL_ID=2593
BRIGHT_ID=2594

get_vol_icon() {
    local vol=$1
    if [ "$vol" -ge 65 ]; then
        echo "audio-volume-high"
    elif [ "$vol" -ge 30 ]; then
        echo "audio-volume-medium"
    else
        echo "audio-volume-low"
    fi
}

send_notification() {
    local id=$1
    local value=$2
    local icon=$3
    local title=$4
    local msg=$5

    if command -v dunstify >/dev/null 2>&1; then
        dunstify -a "OSD" -r "$id" -u low -h int:value:"$value" -i "$icon" "$title" "$msg" -t 1500
    else
        notify-send -r "$id" -h string:x-dunst-stack-tag:osd -h int:value:"$value" -i "$icon" "$title: $msg" -t 1500
    fi
}

case "$1" in
    vol_up)
        pamixer --unmute --increase 5 >/dev/null 2>&1 || true
        vol=$(pamixer --get-volume 2>/dev/null || echo 50)
        icon=$(get_vol_icon "$vol")
        send_notification "$VOL_ID" "$vol" "$icon" "Volumen" "${vol}%"
        ;;
    vol_down)
        pamixer --decrease 5 >/dev/null 2>&1 || true
        vol=$(pamixer --get-volume 2>/dev/null || echo 50)
        icon=$(get_vol_icon "$vol")
        send_notification "$VOL_ID" "$vol" "$icon" "Volumen" "${vol}%"
        ;;
    vol_mute)
        pamixer --toggle-mute >/dev/null 2>&1 || true
        is_muted=$(pamixer --get-mute 2>/dev/null || echo "false")
        if [ "$is_muted" = "true" ]; then
            if command -v dunstify >/dev/null 2>&1; then
                dunstify -a "OSD" -r "$VOL_ID" -u low -h int:value:0 -i audio-volume-muted "Audio" "Silenciado" -t 1500
            else
                notify-send -r "$VOL_ID" -h string:x-dunst-stack-tag:osd -h int:value:0 -i audio-volume-muted "Audio Silenciado" -t 1500
            fi
        else
            vol=$(pamixer --get-volume 2>/dev/null || echo 50)
            icon=$(get_vol_icon "$vol")
            send_notification "$VOL_ID" "$vol" "$icon" "Volumen" "${vol}%"
        fi
        ;;
    bright_up)
        brightnessctl set +5% >/dev/null 2>&1 || true
        bright=$(brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d '%' || true)
        [ -n "$bright" ] && send_notification "$BRIGHT_ID" "$bright" "display-brightness" "Brillo" "${bright}%"
        ;;
    bright_down)
        brightnessctl set 5%- >/dev/null 2>&1 || true
        bright=$(brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d '%' || true)
        [ -n "$bright" ] && send_notification "$BRIGHT_ID" "$bright" "display-brightness" "Brillo" "${bright}%"
        ;;
    *)
        echo "Uso: $0 {vol_up|vol_down|vol_mute|bright_up|bright_down}"
        exit 1
        ;;
esac
