#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

WARNINGS=0
ERRORS=0

status_ok() { ok "$*"; }
status_warn() {
  WARNINGS=$((WARNINGS + 1))
  warn "$*"
}
status_error() {
  ERRORS=$((ERRORS + 1))
  error "$*"
}

check_commands() {
  local commands=(bspwm sxhkd polybar kitty rofi picom feh zsh fc-cache xsettingsd xrdb xsetroot xrandr brightnessctl pamixer pactl flameshot caja)
  for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      status_ok "Comando disponible: $cmd"
    else
      status_error "Comando faltante: $cmd"
    fi
  done

  local optional_commands=(dunst nitrogen xfconf-query synclient i3lock-fancy nvim neofetch htop geany lxterminal xfce4-terminal konsole i3 openbox lxpanel pcmanfm)
  for optional in "${optional_commands[@]}"; do
    if command -v "$optional" >/dev/null 2>&1; then
      status_ok "Opcional disponible: $optional"
    else
      info "Opcional no disponible en este sistema: $optional"
    fi
  done
}

check_packages() {
  local pkg list_file label
  for list_file in "$PROJECT_DIR/packages/apt.txt" "$PROJECT_DIR/packages/optional.txt"; do
    [[ -f "$list_file" ]] || continue
    case "$(basename "$list_file")" in
      optional.txt) label="opcional" ;;
      *) label="requerido" ;;
    esac
  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then
      status_ok "Paquete $label instalado: $pkg"
    elif apt-cache show "$pkg" >/dev/null 2>&1; then
      info "Paquete $label no instalado aquí, disponible para instalar: $pkg"
    else
      status_warn "Paquete $label no instalado y no encontrado en caché apt: $pkg"
    fi
  done < <(read_package_list "$list_file")
  done
}

check_project_paths() {
  local paths=(
    "$PROJECT_DIR/config/bspwm/bspwmrc"
    "$PROJECT_DIR/config/sxhkd/sxhkdrc"
    "$PROJECT_DIR/config/polybar/current.ini"
    "$PROJECT_DIR/config/polybar/launch2.sh"
    "$PROJECT_DIR/config/kitty/kitty.conf"
    "$PROJECT_DIR/config/rofi/config.rasi"
    "$PROJECT_DIR/config/picom/picom.conf"
    "$PROJECT_DIR/config/wallpapers/Fondo6.jpg"
    "$PROJECT_DIR/config/zsh/.zshrc"
    "$PROJECT_DIR/config/zsh/.p10k.zsh"
    "$PROJECT_DIR/config/nvim/init.lua"
    "$PROJECT_DIR/config/nvim/lua/chadrc.lua"
    "$PROJECT_DIR/config/neofetch/config.conf"
    "$PROJECT_DIR/config/htop/htoprc"
    "$PROJECT_DIR/config/geany/geany.conf"
    "$PROJECT_DIR/config/local-share/konsole/Parrot.profile"
    "$PROJECT_DIR/config/editors/vscode/User/settings.json"
    "$PROJECT_DIR/config/i3/config"
    "$PROJECT_DIR/config/openbox/lxde-rc.xml"
    "$PROJECT_DIR/config/lxpanel/LXDE/panels/panel"
    "$PROJECT_DIR/config/pcmanfm/LXDE/pcmanfm.conf"
    "$PROJECT_DIR/config/mate/panel2.d/default/launchers/kitty.desktop"
    "$PROJECT_DIR/config/lxqt/lxqt.conf"
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
    "$PROJECT_DIR/autobspwm"
    "$PROJECT_DIR/install.sh"
    "$PROJECT_DIR/backup.sh"
    "$PROJECT_DIR/restore.sh"
    "$PROJECT_DIR/uninstall.sh"
    "$PROJECT_DIR/check.sh"
    "$PROJECT_DIR/config/bspwm/bspwmrc"
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
  require_user_context
  info "Comprobando proyecto autobspwm-parrot"
  check_project_paths
  check_executables
  check_commands
  check_packages
  check_forbidden_runtime_refs

  info "Resumen: $ERRORS error(es), $WARNINGS warning(s)"
  ((ERRORS == 0)) || exit 1
}

main "$@"
