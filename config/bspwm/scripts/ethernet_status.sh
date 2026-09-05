#!/bin/sh

# Detección dinámica de la interfaz activa con ruta por defecto
IFACE=$(ip -4 route show default 2>/dev/null | awk '/default/ {print $5; exit}')
if [ -z "$IFACE" ]; then
    IFACE=$(ip -4 -o addr show up 2>/dev/null | awk '$2 !~ /^(lo|docker|vboxnet|vmnet|tun|tailscale|wg)/ {print $2; exit}')
fi

IP=$(ip -4 -o addr show dev "$IFACE" 2>/dev/null | awk '{split($4, a, "/"); print a[1]; exit}')

if [ -n "$IP" ]; then
    case "$IFACE" in
        wl*|wlan*) ICON=" " ;;
        *) ICON="󰈀 " ;;
    esac
    echo "%{F#2495e7}$ICON%{F#ffffff}$IP%{u-}"
else
    echo "%{F#2495e7}󰈂 %{F#ffffff}Disconnected%{u-}"
fi
