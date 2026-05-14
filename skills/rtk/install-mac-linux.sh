#!/usr/bin/env bash
# Fase 2.1 — RTK (Rust Token Killer)
#
# Instala o binário rtk e ativa o hook PreToolUse no settings.json do Claude Code.
# Resultado: comandos como `git status` viram `rtk git status` automaticamente,
# economizando 60-90% de tokens em operações de dev.
#
# Idempotente.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/detect-os.sh
source "$SCRIPT_DIR/../../lib/detect-os.sh"

REPO_HOOK="$SCRIPT_DIR/rtk-rewrite.sh"
CLAUDE_HOOKS_DIR="$DESTRAVE_CLAUDE_DIR/hooks"
INSTALLED_HOOK="$CLAUDE_HOOKS_DIR/rtk-rewrite.sh"
SETTINGS_FILE="$DESTRAVE_CLAUDE_DIR/settings.json"

destrave_section "Skill · RTK (token optimizer)"

# --- 1. jq (dependência do hook) --------------------------------------------
if command -v jq >/dev/null 2>&1; then
    destrave_ok "jq já instalado: $(jq --version)"
else
    destrave_info "Instalando jq..."
    case "$DESTRAVE_PKG_MANAGER" in
        brew)   brew install jq ;;
        apt)    sudo apt-get update -qq && sudo apt-get install -y jq ;;
        dnf)    sudo dnf install -y jq ;;
        pacman) sudo pacman -S --noconfirm jq ;;
        *)
            destrave_err "Instale jq manualmente: https://jqlang.github.io/jq/"
            exit 1
            ;;
    esac
fi

# --- 2. rtk binário ---------------------------------------------------------
RTK_MIN_MAJOR=0
RTK_MIN_MINOR=23

install_rtk_brew() {
    destrave_info "Instalando rtk via Homebrew (tap rtk-ai/rtk)..."
    brew tap rtk-ai/rtk 2>/dev/null || true
    brew install rtk-ai/rtk/rtk
}

install_rtk_cargo() {
    if ! command -v cargo >/dev/null 2>&1; then
        destrave_warn "cargo (Rust) não encontrado. RTK precisa dele em Linux/WSL."
        destrave_info "Instalando rustup (toolchain default) — leva ~1 min..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
        # shellcheck disable=SC1091
        source "$HOME/.cargo/env"
    fi
    destrave_info "Instalando rtk via cargo (compila do source — leva 2-5 min)..."
    cargo install rtk-cli --force
}

rtk_version_ok() {
    if ! command -v rtk >/dev/null 2>&1; then
        return 1
    fi
    local v major minor
    v=$(rtk --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    [ -z "$v" ] && return 1
    major=$(echo "$v" | cut -d. -f1)
    minor=$(echo "$v" | cut -d. -f2)
    if [ "$major" -gt "$RTK_MIN_MAJOR" ]; then return 0; fi
    if [ "$major" -eq "$RTK_MIN_MAJOR" ] && [ "$minor" -ge "$RTK_MIN_MINOR" ]; then return 0; fi
    return 1
}

if rtk_version_ok; then
    destrave_ok "rtk já instalado: $(rtk --version)"
else
    case "$DESTRAVE_OS" in
        mac)        install_rtk_brew ;;
        linux|wsl)  install_rtk_cargo ;;
        *)
            destrave_err "OS não suportado pra instalação automática do rtk."
            exit 1
            ;;
    esac
    if ! rtk_version_ok; then
        destrave_err "rtk não está disponível no PATH após instalação. Abra um terminal novo e rode de novo."
        exit 1
    fi
    destrave_ok "rtk instalado: $(rtk --version)"
fi

# --- 3. Hook PreToolUse -----------------------------------------------------
mkdir -p "$CLAUDE_HOOKS_DIR"
cp "$REPO_HOOK" "$INSTALLED_HOOK"
chmod +x "$INSTALLED_HOOK"
destrave_ok "Hook instalado em $INSTALLED_HOOK"

# --- 4. Patch settings.json -------------------------------------------------
mkdir -p "$DESTRAVE_CLAUDE_DIR"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
    destrave_info "Criado settings.json vazio em $SETTINGS_FILE"
fi

# Backup uma única vez
if [ ! -f "$SETTINGS_FILE.destrave-backup" ]; then
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.destrave-backup"
fi

# Adiciona hook PreToolUse → Bash → rtk-rewrite.sh se ainda não existir.
# jq idempotente: só insere se nenhum hook com esse command já estiver lá.
TMP_SETTINGS=$(mktemp)
jq --arg cmd "$INSTALLED_HOOK" '
    .hooks //= {}
    | .hooks.PreToolUse //= []
    | if (.hooks.PreToolUse | map(.hooks // [] | map(.command) | index($cmd)) | any) then
        .
      else
        .hooks.PreToolUse += [{
            "matcher": "Bash",
            "hooks": [{"type": "command", "command": $cmd}]
        }]
      end
' "$SETTINGS_FILE" > "$TMP_SETTINGS"

if ! cmp -s "$SETTINGS_FILE" "$TMP_SETTINGS"; then
    mv "$TMP_SETTINGS" "$SETTINGS_FILE"
    destrave_ok "Hook RTK adicionado a settings.json."
else
    rm -f "$TMP_SETTINGS"
    destrave_ok "Hook RTK já estava registrado em settings.json."
fi

# --- 5. Smoke test ----------------------------------------------------------
destrave_section "Smoke test"
echo '{"tool_input":{"command":"git status"}}' | "$INSTALLED_HOOK" 2>/dev/null | head -5 || true
destrave_ok "RTK pronto. Em uma nova sessão Claude Code, comandos Bash serão reescritos automaticamente."
destrave_info "Conferir economia: rode 'rtk gain' depois de algumas sessões."
