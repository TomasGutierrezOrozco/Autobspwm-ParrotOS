#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ${EUID:-$(id -u)} -eq 0 && -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
  TARGET_USER="${TARGET_USER:-$SUDO_USER}"
  USER_HOME="${USER_HOME:-$(getent passwd "$SUDO_USER" 2>/dev/null | cut -d: -f6 || echo "/home/$SUDO_USER")}"
else
  TARGET_USER="${TARGET_USER:-$(logname 2>/dev/null || echo "${SUDO_USER:-$USER}")}"
  USER_HOME="${USER_HOME:-$HOME}"
fi
BACKUP_ROOT="${BACKUP_ROOT:-$USER_HOME/.backup-autobspwm}"
LOG_DIR="$PROJECT_DIR/logs"
RUN_ID="${RUN_ID:-$(date +%F_%H-%M-%S)}"
LOG_FILE="$LOG_DIR/autobspwm-$RUN_ID.log"
BACKUP_DIR="${BACKUP_DIR:-$BACKUP_ROOT/$RUN_ID}"
ASSUME_YES=0

mkdir -p "$LOG_DIR"

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_OK=$'\033[0;32m'
  C_WARN=$'\033[0;33m'
  C_ERROR=$'\033[0;31m'
  C_INFO=$'\033[0;36m'
  C_MAGENTA=$'\033[0;35m'
  C_BLUE=$'\033[0;34m'
else
  C_RESET=""
  C_BOLD=""
  C_OK=""
  C_WARN=""
  C_ERROR=""
  C_INFO=""
  C_MAGENTA=""
  C_BLUE=""
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

print_banner() {
  cat << "BANNER"

       _         _         _                               
      / \  _   _| |_ ___  | |__  ___ _ ____      ___ __ ___  
     / _ \| | | | __/ _ \ | '_ \/ __| '_ \ \ /\ / / '_ ` _ \ 
    / ___ \ |_| | || (_) || |_) \__ \ |_) \ V  V /| | | | | |
   /_/   \_\__,_|\__\___/ |_.__/|___/ .__/ \_/\_/ |_| |_| |_|
                                     |_|                      
   >> Auto-BSPWM Installer para Parrot Security & Kali Linux <<
   >> Rice & Shell Personalizado por Tomas Gutierrez (Fu11shoot) <<

BANNER
}

prompt_confirm() {
  local prompt="$1"
  local default="${2:-Y}"

  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi

  local choice
  if [[ "$default" =~ ^[Yy]$ ]]; then
    read -r -p "${C_BOLD}${prompt} [S/n]: ${C_RESET}" choice
    choice="${choice:-S}"
    [[ "$choice" =~ ^[sSyY]$ ]]
  else
    read -r -p "${C_BOLD}${prompt} [s/N]: ${C_RESET}" choice
    choice="${choice:-N}"
    [[ "$choice" =~ ^[sSyY]$ ]]
  fi
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

detect_distro() {
  if [[ -r /etc/os-release ]]; then
    if grep -Eqi '^(ID|ID_LIKE)=.*(parrot|kali|debian|ubuntu)' /etc/os-release; then
      echo "debian"
      return 0
    elif grep -Eqi '^(ID|ID_LIKE)=.*(arch|endeavouros|blackarch|manjaro)' /etc/os-release; then
      echo "arch"
      return 0
    fi
  fi
  echo "unknown"
}

has_internet() {
  if command -v curl >/dev/null 2>&1; then
    curl -Is --connect-timeout 5 https://1.1.1.1 >/dev/null 2>&1 && return 0
    curl -Is --connect-timeout 5 https://github.com >/dev/null 2>&1 && return 0
  fi
  if command -v ping >/dev/null 2>&1; then
    ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1 && return 0
  fi
  getent hosts archlinux.org >/dev/null 2>&1 || getent hosts deb.debian.org >/dev/null 2>&1
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
  sed -i "s#file://@/#file://$USER_HOME/#g" "$file"
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
