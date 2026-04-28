#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

backup_targets() {
  cat <<EOF
$USER_HOME/.config/bspwm
$USER_HOME/.config/sxhkd
$USER_HOME/.config/polybar
$USER_HOME/.config/kitty
$USER_HOME/.config/picom
$USER_HOME/.config/rofi
$USER_HOME/.config/gtk-2.0
$USER_HOME/.config/gtk-3.0
$USER_HOME/.config/gtk-4.0
$USER_HOME/.config/xsettingsd
$USER_HOME/.config/flameshot
$USER_HOME/.config/nvim
$USER_HOME/.config/neofetch
$USER_HOME/.config/htop
$USER_HOME/.config/lxterminal
$USER_HOME/.config/xfce4/terminal
$USER_HOME/.config/geany/geany.conf
$USER_HOME/.config/geany/keybindings.conf
$USER_HOME/.config/Visual Studio Code/User/settings.json
$USER_HOME/.config/Windsurf/User/settings.json
$USER_HOME/.config/Windsurf/User/keybindings.json
$USER_HOME/.config/i3
$USER_HOME/.config/openbox
$USER_HOME/.config/lxpanel
$USER_HOME/.config/pcmanfm
$USER_HOME/.config/mate/panel2.d/default/launchers/pluma-1.desktop
$USER_HOME/.config/mate/panel2.d/default/launchers/firefox-selector.desktop
$USER_HOME/.config/mate/panel2.d/default/launchers/kitty.desktop
$USER_HOME/.config/lxqt/lxqt.conf
$USER_HOME/.config/lxqt/lxqt-config-appearance.conf
$USER_HOME/.config/lxqt/lxqt-runner.conf
$USER_HOME/.config/lxqt/notifications.conf
$USER_HOME/.config/lxqt/filedialog.conf
$USER_HOME/.config/bin/target
$USER_HOME/.config/wallpapers
$USER_HOME/.local/bin/toggle-touchpad-synclient
$USER_HOME/.local/share/fonts/autobspwm
$USER_HOME/.local/share/konsole
$USER_HOME/.local/share/applications/mimeapps.list
$USER_HOME/.icons/default
$USER_HOME/.zshrc
$USER_HOME/.p10k.zsh
$USER_HOME/.Xresources
$USER_HOME/.gtkrc-2.0
$USER_HOME/.fehbg
EOF
}

backup_relative_path() {
  local item="$1"
  local rel="${item#"$USER_HOME"/}"
  [[ "$rel" != "$item" ]] || rel="${item#/}"
  printf '%s\n' "$rel"
}

sanitize_text_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -Iq . "$file" || return 0
  perl -ni -e 'print unless /network\s+storage|remote\s+storage|remote\s+mount|file\s+server|fstab|systemd\s+(?:mount|automount)|automount|\/s[r]v\/|\/m[n]t\/|\.smb|credential|credencial|tailscale|mount-/i' "$file"
}

sanitize_backup_copy() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 0
  if [[ -f "$path" ]]; then
    sanitize_text_file "$path"
    return 0
  fi
  if [[ -d "$path" ]]; then
    find "$path" -type f | while read -r file; do
      sanitize_text_file "$file"
    done
  fi
}

main() {
  require_user_context
  safe_mkdir "$BACKUP_DIR"
  info "Creando backup en $BACKUP_DIR"

  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    case "$target" in
      *network-storage*|*remote-storage*|*remote-mount*|*file-server*|*fstab*|*.smb*|*/m[n]t/*|*/s[r]v/*|*tailscale*)
        warn "Excluido por política: $target"
        continue
        ;;
    esac
    rel="$(backup_relative_path "$target")"
    backup_item "$target"
    sanitize_backup_copy "$BACKUP_DIR/$rel"
  done < <(backup_targets)

  ok "Backup finalizado: $BACKUP_DIR"
}

main "$@"
