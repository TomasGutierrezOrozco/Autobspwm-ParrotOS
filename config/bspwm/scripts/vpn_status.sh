#!/bin/sh
 
# Prioridad a interfaces tun (HTB/THM/OpenVPN), seguido de WireGuard y Tailscale
IFACE=$(ip -4 -o addr show 2>/dev/null | awk '$2 ~ /^tun/ {print $2; exit}')
if [ -z "$IFACE" ]; then
    IFACE=$(ip -4 -o addr show 2>/dev/null | awk '$2 ~ /^(wg|tailscale)/ {print $2; exit}')
fi

if [ -n "$IFACE" ]; then
    VPN_IP=$(ip -4 addr show "$IFACE" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
    echo "%{F#1bbf3e}󰆧 %{F#ffffff}${VPN_IP}%{u-}"
else
    echo "%{F#1bbf3e}󰆧 %{F#ffffff}Disconnected%{u-}"
fi
