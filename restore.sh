#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  require_user_context

  local selected="${1:-}"
  if [[ -z "$selected" ]]; then
    selected="$(latest_backup || true)"
  fi
  [[ -n "$selected" ]] || die "No hay backups disponibles en $BACKUP_ROOT"

  local src="$BACKUP_ROOT/$selected"
  [[ -d "$src" ]] || die "Backup no encontrado: $src"

  info "Se restaurará el backup: $src"
  find "$src" -mindepth 1 -maxdepth 4 -print | sed "s#^$src#$USER_HOME#" | tee -a "$LOG_FILE"

  read -r -p "¿Restaurar este backup? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || die "Restauración cancelada"

  cp -a "$src/." "$USER_HOME/"
  ok "Backup restaurado desde $src"
}

main "$@"
