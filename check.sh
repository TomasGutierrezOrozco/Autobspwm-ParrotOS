#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

ERRORS=0
WARNINGS=0

status_ok() {
  ok "$*"
}

status_warn() {
  WARNINGS=$((WARNINGS + 1))
  warn "$*"
}

status_error() {
  ERRORS=$((ERRORS + 1))
  error "$*"
}

check_commands() {
  local commands=(bspwm sxhkd polybar kitty rofi picom feh zsh dunst dunstify pamixer brightnessctl flameshot caja)
  for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      status_ok "Comando disponible: $cmd"
    else
      status_error "Comando faltante: $cmd"
    fi
  done

  local optional_commands=(synclient i3lock-fancy nvim lsd fzf xclip)
  for optional in "${optional_commands[@]}"; do
    if command -v "$optional" >/dev/null 2>&1; then
      status_ok "Opcional disponible: $optional"
    else
      info "Opcional no disponible en este sistema: $optional"
    fi
  done
  if command -v batcat >/dev/null 2>&1; then
    status_ok "Opcional disponible: batcat"
  elif command -v bat >/dev/null 2>&1; then
    status_ok "Opcional disponible: bat"
  else
    info "Opcional no disponible en este sistema: bat / batcat"
  fi
}

check_packages() {
  local distro
  distro="$(detect_distro)"

  if [[ "$distro" == "arch" ]]; then
    local list_file="$PROJECT_DIR/packages/pacman.txt"
    [[ -f "$list_file" ]] || return 0
    while IFS= read -r pkg; do
      [[ -n "$pkg" ]] || continue
      if pacman -Qq "$pkg" >/dev/null 2>&1; then
        status_ok "Paquete pacman instalado: $pkg"
      elif pacman -Si "$pkg" >/dev/null 2>&1; then
        info "Paquete pacman disponible en repositorios: $pkg"
      else
        status_warn "Paquete pacman no encontrado en repositorios: $pkg"
      fi
    done < <(read_package_list "$list_file")
    return 0
  fi

  local pkg list_file label
  for list_file in "$PROJECT_DIR/packages/apt.txt"; do
    [[ -f "$list_file" ]] || continue
    label="requerido"
    while IFS= read -r pkg; do
      [[ -n "$pkg" ]] || continue
      if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
        status_ok "Paquete $label instalado: $pkg"
      elif apt-cache show "$pkg" >/dev/null 2>&1; then
        info "Paquete $label no instalado aquí, disponible para instalar: $pkg"
      else
        status_error "Paquete $label no disponible en apt: $pkg"
      fi
    done < <(read_package_list "$list_file")
  done
}

check_project_paths() {
  local paths=(
    "$PROJECT_DIR/config/bspwm/bspwmrc"
    "$PROJECT_DIR/config/bspwm/scripts/bspwm_resize"
    "$PROJECT_DIR/config/bspwm/scripts/osd.sh"
    "$PROJECT_DIR/config/bspwm/scripts/vpn_status.sh"
    "$PROJECT_DIR/config/bspwm/scripts/ethernet_status.sh"
    "$PROJECT_DIR/config/bspwm/scripts/victim_to_hack.sh"
    "$PROJECT_DIR/config/sxhkd/sxhkdrc"
    "$PROJECT_DIR/config/polybar/current.ini"
    "$PROJECT_DIR/config/polybar/workspace.ini"
    "$PROJECT_DIR/config/polybar/launch2.sh"
    "$PROJECT_DIR/config/kitty/kitty.conf"
    "$PROJECT_DIR/config/kitty/color.ini"
    "$PROJECT_DIR/config/rofi/config.rasi"
    "$PROJECT_DIR/config/rofi/themes/rounded-nord-dark.rasi"
    "$PROJECT_DIR/config/picom/picom.conf"
    "$PROJECT_DIR/config/dunst/dunstrc"
    "$PROJECT_DIR/config/wallpapers/Fondo6.jpg"
    "$PROJECT_DIR/config/fonts/HackNerdFont-Regular.ttf"
    "$PROJECT_DIR/config/fonts/Iosevka Nerd Font Complete.ttf"
    "$PROJECT_DIR/config/zsh/.zshrc"
    "$PROJECT_DIR/config/zsh/.p10k.zsh"
    "$PROJECT_DIR/config/zsh/.p10k-root.zsh"
    "$PROJECT_DIR/config/home/.Xresources"
    "$PROJECT_DIR/config/home/.gtkrc-2.0"
    "$PROJECT_DIR/config/home/.fehbg"
  )
  for path in "${paths[@]}"; do
    if [[ -e "$path" ]]; then
      status_ok "Ruta de proyecto OK: $path"
    else
      status_error "Ruta de proyecto faltante: $path"
    fi
  done
}

check_executables() {
  local scripts=(
    "$PROJECT_DIR/install.sh"
    "$PROJECT_DIR/backup.sh"
    "$PROJECT_DIR/restore.sh"
    "$PROJECT_DIR/uninstall.sh"
    "$PROJECT_DIR/check.sh"
    "$PROJECT_DIR/config/bspwm/bspwmrc"
    "$PROJECT_DIR/config/bspwm/scripts/bspwm_resize"
    "$PROJECT_DIR/config/bspwm/scripts/osd.sh"
    "$PROJECT_DIR/config/bspwm/scripts/vpn_status.sh"
    "$PROJECT_DIR/config/bspwm/scripts/ethernet_status.sh"
    "$PROJECT_DIR/config/bspwm/scripts/victim_to_hack.sh"
    "$PROJECT_DIR/config/polybar/launch.sh"
    "$PROJECT_DIR/config/polybar/launch2.sh"
    "$PROJECT_DIR/config/scripts/local-bin/toggle-touchpad-synclient"
  )
  for script in "${scripts[@]}"; do
    if [[ -x "$script" ]]; then
      status_ok "Ejecutable OK: $script"
    else
      status_warn "No ejecutable: $script"
    fi
  done
}

check_forbidden_runtime_refs() {
  local matches
  matches="$(rg -n '/home/[^/[:space:]]+|/s[r]v/|/m[n]t/|remote[[:space:]_-]?mount|network[[:space:]_-]?storage|\.smb|credential|token|secret|password|private[[:space:]_-]?key' "$PROJECT_DIR/config" "$PROJECT_DIR/system" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    status_error "Referencias no portables o excluidas detectadas:"
    printf '%s\n' "$matches" | tee -a "$LOG_FILE"
  else
    status_ok "Sin rutas personales ni referencias sensibles en config/system"
  fi
}

main() {
  info "Comprobando proyecto Autobspwm-ParrotOS..."
  check_project_paths
  check_executables
  check_commands
  check_packages
  check_forbidden_runtime_refs

  info "Resumen: $ERRORS error(es), $WARNINGS warning(s)"
  [[ "$ERRORS" -eq 0 ]] || exit 1
}

main "$@"
