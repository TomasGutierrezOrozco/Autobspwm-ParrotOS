#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

MANIFEST_DIR="$USER_HOME/.config/autobspwm-parrot"
MANIFEST_FILE="$MANIFEST_DIR/manifest.txt"

install_packages() {
  local apt_file="$PROJECT_DIR/packages/apt.txt"
  mapfile -t packages < <(read_package_list "$apt_file")
  if [[ "${INSTALL_OPTIONAL:-0}" == "1" || "${1:-}" == "--with-optional" ]]; then
    info "Incluyendo paquetes opcionales desde packages/optional.txt"
    mapfile -t optional_packages < <(read_package_list "$PROJECT_DIR/packages/optional.txt")
    packages+=("${optional_packages[@]}")
  fi
  ((${#packages[@]} > 0)) || return 0

  info "Actualizando repositorios apt"
  sudo_cmd apt update

  info "Instalando paquetes requeridos"
  sudo_cmd apt install -y "${packages[@]}"
}

install_powerlevel10k() {
  local dst="$USER_HOME/powerlevel10k"
  [[ -d "$dst" ]] && return 0
  if ! command -v git >/dev/null 2>&1; then
    warn "git no está disponible; Powerlevel10k no se clonó"
    return 0
  fi
  if ! has_internet; then
    warn "Sin conexión; Powerlevel10k no se clonó"
    return 0
  fi
  info "Clonando Powerlevel10k en $dst"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dst"
}

write_manifest() {
  safe_mkdir "$MANIFEST_DIR"
  cat > "$MANIFEST_FILE" <<EOF
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

install_configs() {
  info "Creando backup previo a la instalación"
  "$PROJECT_DIR/backup.sh"

  info "Copiando configuraciones de usuario"
  copy_dir_contents "$PROJECT_DIR/config/bspwm" "$USER_HOME/.config/bspwm"
  copy_dir_contents "$PROJECT_DIR/config/sxhkd" "$USER_HOME/.config/sxhkd"
  copy_dir_contents "$PROJECT_DIR/config/polybar" "$USER_HOME/.config/polybar"
  copy_dir_contents "$PROJECT_DIR/config/kitty" "$USER_HOME/.config/kitty"
  copy_dir_contents "$PROJECT_DIR/config/picom" "$USER_HOME/.config/picom"
  copy_dir_contents "$PROJECT_DIR/config/rofi" "$USER_HOME/.config/rofi"
  copy_dir_contents "$PROJECT_DIR/config/gtk-2.0" "$USER_HOME/.config/gtk-2.0"
  copy_dir_contents "$PROJECT_DIR/config/gtk-3.0" "$USER_HOME/.config/gtk-3.0"
  copy_dir_contents "$PROJECT_DIR/config/gtk-4.0" "$USER_HOME/.config/gtk-4.0"
  copy_dir_contents "$PROJECT_DIR/config/xsettingsd" "$USER_HOME/.config/xsettingsd"
  copy_dir_contents "$PROJECT_DIR/config/flameshot" "$USER_HOME/.config/flameshot"
  copy_dir_contents "$PROJECT_DIR/config/nvim" "$USER_HOME/.config/nvim"
  copy_dir_contents "$PROJECT_DIR/config/neofetch" "$USER_HOME/.config/neofetch"
  copy_dir_contents "$PROJECT_DIR/config/htop" "$USER_HOME/.config/htop"
  copy_dir_contents "$PROJECT_DIR/config/lxterminal" "$USER_HOME/.config/lxterminal"
  copy_dir_contents "$PROJECT_DIR/config/xfce4/terminal" "$USER_HOME/.config/xfce4/terminal"
  copy_dir_contents "$PROJECT_DIR/config/geany" "$USER_HOME/.config/geany"
  copy_dir_contents "$PROJECT_DIR/config/local-share/konsole" "$USER_HOME/.local/share/konsole"
  copy_dir_contents "$PROJECT_DIR/config/local-share/applications" "$USER_HOME/.local/share/applications"
  copy_dir_contents "$PROJECT_DIR/config/editors/vscode/User" "$USER_HOME/.config/Visual Studio Code/User"
  copy_dir_contents "$PROJECT_DIR/config/editors/windsurf/User" "$USER_HOME/.config/Windsurf/User"
  copy_dir_contents "$PROJECT_DIR/config/i3" "$USER_HOME/.config/i3"
  copy_dir_contents "$PROJECT_DIR/config/openbox" "$USER_HOME/.config/openbox"
  copy_dir_contents "$PROJECT_DIR/config/lxpanel" "$USER_HOME/.config/lxpanel"
  copy_dir_contents "$PROJECT_DIR/config/pcmanfm" "$USER_HOME/.config/pcmanfm"
  copy_dir_contents "$PROJECT_DIR/config/mate" "$USER_HOME/.config/mate"
  copy_dir_contents "$PROJECT_DIR/config/lxqt" "$USER_HOME/.config/lxqt"
  copy_dir_contents "$PROJECT_DIR/config/wallpapers" "$USER_HOME/.config/wallpapers"
  copy_dir_contents "$PROJECT_DIR/config/fonts" "$USER_HOME/.local/share/fonts/autobspwm"
  copy_dir_contents "$PROJECT_DIR/config/icons" "$USER_HOME/.icons"
  copy_dir_contents "$PROJECT_DIR/config/bin" "$USER_HOME/.config/bin"
  copy_dir_contents "$PROJECT_DIR/config/scripts/local-bin" "$USER_HOME/.local/bin"

  copy_path "$PROJECT_DIR/config/zsh/.zshrc" "$USER_HOME/.zshrc"
  copy_path "$PROJECT_DIR/config/zsh/.p10k.zsh" "$USER_HOME/.p10k.zsh"
  copy_path "$PROJECT_DIR/config/home/.Xresources" "$USER_HOME/.Xresources"
  copy_path "$PROJECT_DIR/config/home/.gtkrc-2.0" "$USER_HOME/.gtkrc-2.0"
  copy_path "$PROJECT_DIR/config/home/.fehbg" "$USER_HOME/.fehbg"

  replace_user_home_placeholder "$USER_HOME/.config/gtk-3.0/bookmarks"

  ensure_executable "$USER_HOME/.config/bspwm/bspwmrc"
  find "$USER_HOME/.config/bspwm/scripts" "$USER_HOME/.config/polybar/scripts" "$USER_HOME/.local/bin" -maxdepth 2 -type f -name '*.sh' -o -type f -name 'bspwm_resize' -o -type f -name 'launcher' -o -type f -name 'powermenu*' -o -type f -name 'toggle-touchpad-synclient' | while read -r script; do
    ensure_executable "$script"
  done
  ensure_executable "$USER_HOME/.config/polybar/launch.sh"
  ensure_executable "$USER_HOME/.config/polybar/launch2.sh"
  ensure_executable "$USER_HOME/.fehbg"

  info "Refrescando caché de fuentes"
  fc-cache -fv "$USER_HOME/.local/share/fonts" >/dev/null

  apply_themes
  install_xsession
  install_powerlevel10k
  write_manifest
  ok "Instalación completada"
}

apply_themes() {
  info "Aplicando tema GTK/iconos/cursor cuando sea posible"
  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || true
    gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Green-Dark' || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
  fi
  if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -s 'Adwaita-dark' || true
    xfconf-query -c xsettings -p /Net/IconThemeName -s 'Flat-Remix-Green-Dark' || true
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s 'Bibata-Modern-Ice' || true
  fi
}

install_xsession() {
  local desktop_file="$PROJECT_DIR/system/xsession/bspwm-autobspwm.desktop"
  [[ -f "$desktop_file" ]] || return 0
  info "Instalando entrada de sesión BSPWM en /usr/share/xsessions"
  sudo_cmd install -Dm644 "$desktop_file" /usr/share/xsessions/bspwm-autobspwm.desktop
}

main() {
  require_user_context
  is_debian_based || die "Este instalador requiere Parrot/Debian-based"
  has_internet || die "No se detectó conexión a internet"
  install_packages "${1:-}"
  install_configs
}

main "$@"
