#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

MANIFEST_FILE="$USER_HOME/.config/autobspwm-parrot/manifest.txt"
REMOVED_DIR="$BACKUP_ROOT/uninstall_$RUN_ID"

remove_installed_configs() {
  [[ -f "$MANIFEST_FILE" ]] || {
    warn "No existe manifest de instalación: $MANIFEST_FILE"
    return 0
  }

  safe_mkdir "$REMOVED_DIR"
  info "Moviendo configuraciones instaladas a $REMOVED_DIR"

  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    [[ -e "$target" || -L "$target" ]] || continue
    [[ "$target" == "$USER_HOME/"* ]] || {
      warn "Ruta fuera de HOME ignorada: $target"
      continue
    }
    local rel="${target#"$USER_HOME"/}"
    safe_mkdir "$REMOVED_DIR/$(dirname "$rel")"
    mv "$target" "$REMOVED_DIR/$rel"
    info "Retirado: $target"
  done < "$MANIFEST_FILE"
}

maybe_restore_backup() {
  local selected
  selected="$(latest_backup || true)"
  [[ -n "$selected" ]] || {
    warn "No hay backup previo para restaurar"
    return 0
  }

  read -r -p "¿Restaurar el último backup ($selected)? [Y/n] " answer
  if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
    "$PROJECT_DIR/restore.sh" "$selected"
  else
    warn "No se restauró backup previo"
  fi
}

maybe_remove_packages() {
  read -r -p "¿Eliminar paquetes apt listados en packages/apt.txt? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || {
    info "No se eliminaron paquetes"
    return 0
  }

  mapfile -t packages < <(read_package_list "$PROJECT_DIR/packages/apt.txt")
  ((${#packages[@]} > 0)) || return 0
  sudo_cmd apt remove -y "${packages[@]}"
  warn "Revisa manualmente paquetes huérfanos antes de usar apt autoremove"
}

main() {
  require_user_context
  remove_installed_configs
  maybe_restore_backup
  maybe_remove_packages
  ok "Desinstalación finalizada"
}

main "$@"
