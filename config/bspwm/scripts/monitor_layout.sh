#!/bin/sh

INTERNAL=$(xrandr | awk '/ connected primary/{print $1; exit}')
[ -z "$INTERNAL" ] && INTERNAL=$(xrandr | awk '/ connected/{print $1; exit}')

EXTERNAL=$(xrandr | awk '/ connected/{print $1}' | grep -v "$INTERNAL" | head -n1)

# Ajusta estos modos si tu hardware usa otras resoluciones
TARGET_INT_MODE="1920x1200"  # resolución del portátil
TARGET_EXT_MODE="1920x1080"  # resolución física del monitor externo

case "$1" in
  extend)
    # Extender a la izquierda
    if [ -n "$EXTERNAL" ]; then
      xrandr --output "$INTERNAL" --auto --primary \
             --output "$EXTERNAL" --auto --left-of "$INTERNAL"
    else
      # Solo interna si no hay monitor externo
      xrandr --output "$INTERNAL" --auto --primary
    fi
    ;;

  mirror)
    # Duplicar usando el modo preferido del monitor EXTERNO (limpio)
    if [ -n "$EXTERNAL" ]; then
      MODE_EXT=$(xrandr | awk -v mon="$EXTERNAL" '
        $0 ~ "^"mon" " {found=1}
        found && /\*/ {print $1; exit}')
      [ -z "$MODE_EXT" ] && exit 1

      xrandr --output "$INTERNAL" --mode "$MODE_EXT" --primary \
             --output "$EXTERNAL" --mode "$MODE_EXT" --same-as "$INTERNAL"
    fi
    ;;

  mirror_scaled)
    # Mantener 1920x1200 en el portátil y escalar al externo
    if [ -n "$EXTERNAL" ]; then
      xrandr --output "$INTERNAL" --mode "$TARGET_INT_MODE" --primary \
             --output "$EXTERNAL" --mode "$TARGET_EXT_MODE" \
             --scale-from "$TARGET_INT_MODE" --same-as "$INTERNAL"
    fi
    ;;

  internal)
    # Solo pantalla interna
    xrandr --output "$INTERNAL" --auto --primary
    [ -n "$EXTERNAL" ] && xrandr --output "$EXTERNAL" --off
    ;;
esac
