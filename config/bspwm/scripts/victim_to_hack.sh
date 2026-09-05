#!/bin/bash

ip_address=$(awk '{print $1}' "$HOME/.config/bin/target" 2>/dev/null)
machine_name=$(awk '{$1=""; sub(/^[ \t]+/, ""); print}' "$HOME/.config/bin/target" 2>/dev/null)

if [ -n "$ip_address" ] && [ -n "$machine_name" ]; then
    echo "%{F#e51d0b}󰯐 %{F#ffffff}$ip_address%{u-} - $machine_name"
elif [ -n "$ip_address" ]; then
    echo "%{F#e51d0b}󰯐 %{F#ffffff}$ip_address%{u-}"
else
    echo "%{F#e51d0b}󰯐 %{u-}%{F#ffffff} No target"
fi
