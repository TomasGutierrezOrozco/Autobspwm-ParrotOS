#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_HOME="${USER_HOME:-$HOME}"
BACKUP_ROOT="${BACKUP_ROOT:-$USER_HOME/.backup-autobspwm}"
LOG_DIR="$PROJECT_DIR/logs"
RUN_ID="${RUN_ID:-$(date +%F_%H-%M-%S)}"
LOG_FILE="$LOG_DIR/autobspwm-$RUN_ID.log"
BACKUP_DIR="${BACKUP_DIR:-$BACKUP_ROOT/$RUN_ID}"

mkdir -p "$LOG_DIR"

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_OK=$'\033[0;32m'
  C_WARN=$'\033[0;33m'
  C_ERROR=$'\033[0;31m'
  C_INFO=$'\033[0;36m'
else
  C_RESET=""
  C_OK=""
  C_WARN=""
  C_ERROR=""
  C_INFO=""
fi

log() {
  local level="$1"
  local color="$2"
  shift 2
  printf '%s[%s]%s %s\n' "$color" "$level" "$C_RESET" "$*" | tee -a "$LOG_FILE"
}

ok() { log "OK" "$C_OK" "$*"; }
info() { log "INFO" "$C_INFO" "$*"; }
warn() { log "WARN" "$C_WARN" "$*"; }
error() { log "ERROR" "$C_ERROR" "$*"; }
die() {
  error "$*"
  exit 1
}

require_user_context() {
  [[ "$USER_HOME" != "/" ]] || die "USER_HOME no puede ser /"
  [[ -d "$USER_HOME" ]] || die "USER_HOME no existe: $USER_HOME"
}

sudo_cmd() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

read_package_list() {
  local file="$1"
  sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$file"
}

is_debian_based() {
  [[ -r /etc/os-release ]] || return 1
  grep -Eqi '^(ID|ID_LIKE)=.*(debian|parrot|ubuntu)' /etc/os-release
}

has_internet() {
  if command -v curl >/dev/null 2>&1; then
    curl -Is --connect-timeout 5 https://deb.debian.org >/dev/null 2>&1 && return 0
  fi
  if command -v ping >/dev/null 2>&1; then
    ping -c 1 -W 3 deb.debian.org >/dev/null 2>&1 && return 0
  fi
  getent hosts deb.debian.org >/dev/null 2>&1
}

safe_mkdir() {
  local dir="$1"
  [[ -n "$dir" && "$dir" != "/" ]] || die "Ruta de directorio insegura: $dir"
  mkdir -p "$dir"
}

copy_path() {
  local src="$1"
  local dst="$2"
  [[ -e "$src" ]] || return 0
  safe_mkdir "$(dirname "$dst")"
  cp -a "$src" "$dst"
}

copy_dir_contents() {
  local src="$1"
  local dst="$2"
  [[ -d "$src" ]] || return 0
  safe_mkdir "$dst"
  cp -a "$src/." "$dst/"
}

replace_user_home_placeholder() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  sed -i "s#@USER_HOME@#$USER_HOME#g" "$file"
}

backup_item() {
  local item="$1"
  local rel
  [[ -e "$item" || -L "$item" ]] || return 0
  rel="${item#"$USER_HOME"/}"
  [[ "$rel" != "$item" ]] || rel="${item#/}"
  safe_mkdir "$BACKUP_DIR/$(dirname "$rel")"
  cp -a "$item" "$BACKUP_DIR/$rel"
  info "Backup: $item -> $BACKUP_DIR/$rel"
}

latest_backup() {
  [[ -d "$BACKUP_ROOT" ]] || return 1
  find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -name '????-??-??_??-??-??' -printf '%f\n' | sort | tail -n 1
}

ensure_executable() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  chmod +x "$path"
}
