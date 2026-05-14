#!/usr/bin/env bash
# Fase 2.5 — /done (ritual de fim de sessão)
# Copia SKILL.md pra ~/.claude/skills/done/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/detect-os.sh
source "$SCRIPT_DIR/../../lib/detect-os.sh"

SRC="$SCRIPT_DIR/SKILL.md"
DEST_DIR="$DESTRAVE_CLAUDE_DIR/skills/done"
DEST="$DEST_DIR/SKILL.md"

destrave_section "Skill · /done"

if [ ! -f "$SRC" ]; then
    destrave_err "SKILL.md não encontrado em $SRC"
    exit 1
fi

mkdir -p "$DEST_DIR"

# Se já existe e o usuário customizou (tem calibrações), preserva.
if [ -f "$DEST" ]; then
    if grep -qE '^- \[202[0-9]-' "$DEST"; then
        destrave_warn "$DEST já tem calibrações registradas. Preservando arquivo atual."
        destrave_info "Pra forçar overwrite: rm $DEST && rode de novo."
        exit 0
    fi
    destrave_info "Sobrescrevendo $DEST (sem calibrações próprias)."
fi

cp "$SRC" "$DEST"
destrave_ok "Skill /done instalada em $DEST"
destrave_info "Em sessão Claude Code: digite '/done' ao terminar uma etapa, task ou projeto."
destrave_info "Pra ativar ClickUp opt-in: crie ~/.claude/state/clickup-config.json (instruções no SKILL.md)."
