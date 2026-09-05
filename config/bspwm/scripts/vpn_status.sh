#!/bin/sh
 
if [ -d /sys/class/net/tun0 ]; then
    VPN_IP=$(ip -4 addr show tun0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
    echo "%{F#1bbf3e}󰆧 %{F#ffffff}${VPN_IP}%{u-}"
elif [ -d /sys/class/net/tailscale0 ]; then
    VPN_IP=$(ip -4 addr show tailscale0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
    echo "%{F#1bbf3e}󰆧 %{F#ffffff}${VPN_IP}%{u-}"
elif [ -d /sys/class/net/wg0 ]; then
    VPN_IP=$(ip -4 addr show wg0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
    echo "%{F#1bbf3e}󰆧 %{F#ffffff}${VPN_IP}%{u-}"
else
    echo "%{F#1bbf3e}󰆧 %{u-} Disconnected"
fi
