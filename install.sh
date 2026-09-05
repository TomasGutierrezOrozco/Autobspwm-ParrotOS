#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

MANIFEST_DIR="$USER_HOME/.config/autobspwm-parrot"
MANIFEST_FILE="$MANIFEST_DIR/manifest.txt"
CONFIGURE_ROOT=1

usage() {
  cat << "USAGE_BLOCK"
Uso: ./install.sh [OPCIONES]

Opciones:
  -y, --yes            Modo no interactivo (asume 'Sí' a todas las preguntas)
  --no-root            Omite la configuración y paridad con el usuario root
  --help, -h           Muestra esta ayuda y sale

USAGE_BLOCK
  exit 0
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -y|--yes)
        ASSUME_YES=1
        shift
        ;;
      --no-root)
        CONFIGURE_ROOT=0
        shift
        ;;
      --help|-h)
        usage
        ;;
      *)
        warn "Opción desconocida: $1"
        shift
        ;;
    esac
  done
}

install_packages() {
  local apt_file="$PROJECT_DIR/packages/apt.txt"
  mapfile -t packages < <(read_package_list "$apt_file")
  ((${#packages[@]} > 0)) || return 0

  info "Actualizando repositorios apt..."
  sudo_cmd apt update

  info "Instalando paquetes y dependencias base del entorno..."
  sudo_cmd apt install -y "${packages[@]}"
  ok "Paquetes instalados correctamente."
}

install_fonts() {
  info "Instalando tipografías (Hack Nerd Font, Iosevka, Feather, Helvetica)..."
  sudo_cmd mkdir -p "/usr/local/share/fonts/autobspwm"
  sudo_cmd cp -a "$PROJECT_DIR/config/fonts/." "/usr/local/share/fonts/autobspwm/"
  
  safe_mkdir "$USER_HOME/.local/share/fonts/autobspwm"
  cp -a "$PROJECT_DIR/config/fonts/." "$USER_HOME/.local/share/fonts/autobspwm/"

  info "Actualizando la caché de tipografías del sistema..."
  sudo_cmd fc-cache -fv "/usr/local/share/fonts/autobspwm" >/dev/null 2>&1 || true
  fc-cache -fv "$USER_HOME/.local/share/fonts" >/dev/null 2>&1 || true
  ok "Tipografías instaladas y caché refrescada."
}

install_powerlevel10k() {
  local dst="$USER_HOME/powerlevel10k"
  if [[ -d "$dst" ]]; then
    ok "Powerlevel10k ya se encuentra clonado en $dst."
    return 0
  fi
  if ! has_internet; then
    warn "Sin conexión a internet; Powerlevel10k no se pudo clonar automáticamente."
    return 0
  fi
  info "Clonando Powerlevel10k en $dst..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dst"
  ok "Powerlevel10k clonado con éxito."
}

write_manifest() {
  safe_mkdir "$MANIFEST_DIR"
  cat > "$MANIFEST_FILE" << MANIFEST_BLOCK
$USER_HOME/.config/bspwm
$USER_HOME/.config/sxhkd
$USER_HOME/.config/polybar
$USER_HOME/.config/kitty
$USER_HOME/.config/picom
$USER_HOME/.config/dunst
$USER_HOME/.config/rofi
$USER_HOME/.config/gtk-2.0
$USER_HOME/.config/gtk-3.0
$USER_HOME/.config/gtk-4.0
$USER_HOME/.config/xsettingsd
$USER_HOME/.config/flameshot
$USER_HOME/.config/nvim
$USER_HOME/.config/bin/target
$USER_HOME/.config/wallpapers
$USER_HOME/.local/bin/toggle-touchpad-synclient
$USER_HOME/.local/share/fonts/autobspwm
$USER_HOME/.local/share/dbus-1/services/org.freedesktop.Notifications.service
$USER_HOME/.local/share/dbus-1/services/org.freedesktop.mate.Notifications.service
$USER_HOME/.zshrc
$USER_HOME/.p10k.zsh
$USER_HOME/.Xresources
$USER_HOME/.gtkrc-2.0
$USER_HOME/.fehbg
MANIFEST_BLOCK
}

install_configs() {
  info "Creando copia de seguridad previa en $BACKUP_DIR..."
  "$PROJECT_DIR/backup.sh"

  info "Desplegando archivos de configuración en $USER_HOME/.config..."
  copy_dir_contents "$PROJECT_DIR/config/bspwm" "$USER_HOME/.config/bspwm"
  copy_dir_contents "$PROJECT_DIR/config/sxhkd" "$USER_HOME/.config/sxhkd"
  copy_dir_contents "$PROJECT_DIR/config/polybar" "$USER_HOME/.config/polybar"
  copy_dir_contents "$PROJECT_DIR/config/kitty" "$USER_HOME/.config/kitty"
  copy_dir_contents "$PROJECT_DIR/config/picom" "$USER_HOME/.config/picom"
  copy_dir_contents "$PROJECT_DIR/config/dunst" "$USER_HOME/.config/dunst"
  copy_dir_contents "$PROJECT_DIR/config/rofi" "$USER_HOME/.config/rofi"
  copy_dir_contents "$PROJECT_DIR/config/gtk-2.0" "$USER_HOME/.config/gtk-2.0"
  copy_dir_contents "$PROJECT_DIR/config/gtk-3.0" "$USER_HOME/.config/gtk-3.0"
  copy_dir_contents "$PROJECT_DIR/config/gtk-4.0" "$USER_HOME/.config/gtk-4.0"
  copy_dir_contents "$PROJECT_DIR/config/xsettingsd" "$USER_HOME/.config/xsettingsd"
  copy_dir_contents "$PROJECT_DIR/config/flameshot" "$USER_HOME/.config/flameshot"
  copy_dir_contents "$PROJECT_DIR/config/nvim" "$USER_HOME/.config/nvim"
  copy_dir_contents "$PROJECT_DIR/config/wallpapers" "$USER_HOME/.config/wallpapers"
  copy_dir_contents "$PROJECT_DIR/config/bin" "$USER_HOME/.config/bin"
  copy_dir_contents "$PROJECT_DIR/config/scripts/local-bin" "$USER_HOME/.local/bin"

  info "Desplegando configuraciones de home y shell..."
  copy_path "$PROJECT_DIR/config/zsh/.zshrc" "$USER_HOME/.zshrc"
  copy_path "$PROJECT_DIR/config/zsh/.p10k.zsh" "$USER_HOME/.p10k.zsh"
  copy_path "$PROJECT_DIR/config/home/.Xresources" "$USER_HOME/.Xresources"
  copy_path "$PROJECT_DIR/config/home/.gtkrc-2.0" "$USER_HOME/.gtkrc-2.0"
  copy_path "$PROJECT_DIR/config/home/.fehbg" "$USER_HOME/.fehbg"

  replace_user_home_placeholder "$USER_HOME/.config/gtk-3.0/bookmarks"

  info "Configurando prioridad exclusiva de D-Bus para Dunst..."
  safe_mkdir "$USER_HOME/.local/share/dbus-1/services"
  copy_path "$PROJECT_DIR/system/dbus/org.freedesktop.Notifications.service" "$USER_HOME/.local/share/dbus-1/services/org.freedesktop.Notifications.service"
  copy_path "$PROJECT_DIR/system/dbus/org.freedesktop.mate.Notifications.service" "$USER_HOME/.local/share/dbus-1/services/org.freedesktop.mate.Notifications.service"

  info "Asignando permisos de ejecución a los scripts..."
  ensure_executable "$USER_HOME/.config/bspwm/bspwmrc"
  find "$USER_HOME/.config/bspwm/scripts" "$USER_HOME/.config/polybar/scripts" "$USER_HOME/.local/bin" -maxdepth 2 -type f | while read -r script; do
    ensure_executable "$script"
  done
  ensure_executable "$USER_HOME/.config/polybar/launch.sh"
  ensure_executable "$USER_HOME/.config/polybar/launch2.sh"
  ensure_executable "$USER_HOME/.fehbg"

  apply_themes
  install_xsession
  install_powerlevel10k
  write_manifest
  ok "Configuraciones desplegadas correctamente."
}

apply_themes() {
  info "Sincronizando temas GTK, cursores e iconos..."
  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Green-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'breeze_cursors' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  fi
  if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -s 'Adwaita-dark' 2>/dev/null || true
    xfconf-query -c xsettings -p /Net/IconThemeName -s 'Flat-Remix-Green-Dark' 2>/dev/null || true
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s 'breeze_cursors' 2>/dev/null || true
  fi
}

install_xsession() {
  local desktop_file="$PROJECT_DIR/system/xsession/bspwm-autobspwm.desktop"
  [[ -f "$desktop_file" ]] || return 0
  info "Registrando sesión de BSPWM en el gestor de inicio (/usr/share/xsessions)..."
  sudo_cmd install -Dm644 "$desktop_file" /usr/share/xsessions/bspwm-autobspwm.desktop
  sudo_cmd install -Dm644 "$desktop_file" /usr/share/xsessions/bspwm.desktop
}

sync_root_user() {
  info "Sincronizando entorno para el usuario root..."
  sudo_cmd mkdir -p "/root/.config"
  sudo_cmd mkdir -p "/root/.config/kitty"
  sudo_cmd mkdir -p "/root/.config/nvim"

  info "Enlazando /root/.zshrc -> $USER_HOME/.zshrc"
  sudo_cmd ln -sf "$USER_HOME/.zshrc" /root/.zshrc

  info "Configurando /root/.p10k.zsh (con icono de la llama '󰈸')..."
  sudo_cmd cp -a "$PROJECT_DIR/config/zsh/.p10k-root.zsh" /root/.p10k.zsh

  if [[ ! -d "/root/powerlevel10k" ]]; then
    if [[ -d "$USER_HOME/powerlevel10k" ]]; then
      info "Replicando Powerlevel10k local en root..."
      sudo_cmd cp -a "$USER_HOME/powerlevel10k" /root/powerlevel10k
    elif has_internet; then
      info "Clonando Powerlevel10k para root..."
      sudo_cmd git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k 2>/dev/null || true
    fi
  fi

  info "Replicando configuraciones de Kitty y Neovim en root..."
  sudo_cmd cp -a "$PROJECT_DIR/config/kitty/." /root/.config/kitty/
  sudo_cmd cp -a "$PROJECT_DIR/config/nvim/." /root/.config/nvim/

  local zsh_bin
  zsh_bin="$(which zsh 2>/dev/null || echo '/usr/bin/zsh')"
  info "Cambiando la shell de root a Zsh..."
  sudo_cmd chsh -s "$zsh_bin" root 2>/dev/null || true
  ok "Usuario root sincronizado con éxito."
}

set_default_shell() {
  local zsh_bin
  zsh_bin="$(which zsh 2>/dev/null || echo '/usr/bin/zsh')"
  if [[ "${SHELL:-}" != "$zsh_bin" ]]; then
    if prompt_confirm "¿Deseas cambiar tu shell predeterminada a Zsh?" "Y"; then
      info "Cambiando la shell de $TARGET_USER a $zsh_bin..."
      chsh -s "$zsh_bin" "$TARGET_USER" 2>/dev/null || sudo_cmd chsh -s "$zsh_bin" "$TARGET_USER"
      ok "Shell predeterminada cambiada a Zsh."
    fi
  else
    ok "La shell predeterminada ya es Zsh."
  fi
}

main() {
  print_banner
  parse_args "$@"

  require_user_context

  local distro
  distro="$(detect_distro)"
  if [[ "$distro" == "arch" ]]; then
    die "Se detectó Arch Linux. El soporte para Arch está planeado para la Fase 2 de Autobspwm. Actualmente este instalador soporta Parrot Security OS y Kali Linux."
  elif [[ "$distro" != "debian" ]]; then
    warn "Distribución no identificada directamente como Debian/Parrot/Kali. Continuando bajo tu propio riesgo..."
  fi

  cat << "RESUMEN"
Componentes a instalar y configurar:
  * Window Manager: bspwm + sxhkd
  * Barra de estado: Polybar (arquitectura de 8 islas modulares)
  * Compositor X11: Picom (optimizado con use-damage=true y dual_kawase)
  * Notificaciones / OSD: Dunst (Nord theme, barra de volumen y brillo en tiempo real)
  * Lanzador: Rofi (modo drun con tema rounded-nord-dark)
  * Terminal: Kitty (Tokyo Night)
  * Shell: Zsh + Powerlevel10k + utilidades CLI (lsd, batcat, fzf)
  * Tipografías: Hack Nerd Font completa, Iosevka, Feather, Helvetica
  * Fondo de pantalla: Colección de fondos en ~/.config/wallpapers

RESUMEN

  if ! prompt_confirm "¿Deseas iniciar la instalación completa de Autobspwm?" "Y"; then
    info "Instalación cancelada por el usuario."
    exit 0
  fi

  has_internet || warn "No se detectó conexión a internet activa. Es posible que la descarga de paquetes falle."

  install_packages
  install_fonts
  install_configs

  if [[ "$CONFIGURE_ROOT" -eq 1 ]]; then
    if prompt_confirm "¿Deseas configurar y sincronizar el entorno para el usuario root (Pentesting & flame icon)?" "Y"; then
      sync_root_user
    fi
  fi

  set_default_shell

  cat << "FINAL"

========================================================================
           ¡INSTALACIÓN DE AUTO-BSPWM COMPLETADA CON ÉXITO!
========================================================================

Atajos rápidos del entorno:
  * [Super + Enter]         Abrir terminal Kitty
  * [Super + d]             Lanzador de aplicaciones (Rofi drun)
  * [Super + Shift + q]     Cerrar ventana enfocada
  * [Super + 1 - 0]         Cambiar de escritorio virtual
  * [Teclas Volumen/Brillo] Control interactivo con OSD en tiempo real
  * [Super + Alt + s]       Captura de pantalla interactiva (Flameshot)
  * [Print]                 Captura de pantalla rápida (Flameshot)
  * [Super + Shift + r]     Recargar BSPWM

Próximos pasos recomendados:
  1. Cierra sesión o reinicia tu equipo: 'sudo reboot'
  2. En la pantalla de inicio de sesión (Display Manager), selecciona 'bspwm' como sesión.
  3. ¡Disfruta de tu nuevo entorno!

FINAL
}

main "$@"
