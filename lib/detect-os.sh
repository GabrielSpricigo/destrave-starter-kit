#!/usr/bin/env bash
# detect-os.sh — detecta SO e exporta variáveis usadas pelos installers.
#
# Uso (em outro script bash):
#   source "$(dirname "$0")/../lib/detect-os.sh"
#   echo "$DESTRAVE_OS"          # mac | linux | wsl
#   echo "$DESTRAVE_PKG_MANAGER" # brew | apt | dnf | pacman | unknown
#   echo "$DESTRAVE_CLAUDE_DIR"  # ~/.claude

set -euo pipefail

DESTRAVE_OS="unknown"
DESTRAVE_PKG_MANAGER="unknown"
DESTRAVE_ARCH="$(uname -m)"

case "$(uname -s)" in
  Darwin)
    DESTRAVE_OS="mac"
    if command -v brew >/dev/null 2>&1; then
      DESTRAVE_PKG_MANAGER="brew"
    fi
    ;;
  Linux)
    if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
      DESTRAVE_OS="wsl"
    else
      DESTRAVE_OS="linux"
    fi
    if command -v apt-get >/dev/null 2>&1; then
      DESTRAVE_PKG_MANAGER="apt"
    elif command -v dnf >/dev/null 2>&1; then
      DESTRAVE_PKG_MANAGER="dnf"
    elif command -v pacman >/dev/null 2>&1; then
      DESTRAVE_PKG_MANAGER="pacman"
    fi
    ;;
  *)
    DESTRAVE_OS="unknown"
    ;;
esac

DESTRAVE_CLAUDE_DIR="${HOME}/.claude"

export DESTRAVE_OS DESTRAVE_PKG_MANAGER DESTRAVE_ARCH DESTRAVE_CLAUDE_DIR

# Helpers de log (cores ANSI básicas, sem dependências)
destrave_info()    { printf "\033[1;34mℹ\033[0m  %s\n" "$*"; }
destrave_ok()      { printf "\033[1;32m✓\033[0m  %s\n" "$*"; }
destrave_warn()    { printf "\033[1;33m⚠\033[0m  %s\n" "$*" >&2; }
destrave_err()     { printf "\033[1;31m✗\033[0m  %s\n" "$*" >&2; }
destrave_section() { printf "\n\033[1;36m==\033[0m \033[1m%s\033[0m\n" "$*"; }
