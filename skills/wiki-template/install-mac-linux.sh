#!/usr/bin/env bash
# Fase 2.4 — Wiki template
# Copia o esqueleto da wiki pra um destino escolhido pelo mentorado.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/detect-os.sh
source "$SCRIPT_DIR/../../lib/detect-os.sh"

TEMPLATE_DIR="$SCRIPT_DIR/template"

destrave_section "Skill · Wiki template"

if [ ! -d "$TEMPLATE_DIR" ]; then
    destrave_err "Template não encontrado em $TEMPLATE_DIR"
    exit 1
fi

# --- Onde colocar a wiki ----------------------------------------------------
DEFAULT_DEST="${DESTRAVE_WIKI_DEST:-$PWD/wiki}"

if [ -t 0 ]; then
    echo ""
    printf "Onde criar a wiki? [%s] " "$DEFAULT_DEST"
    read -r dest_input
    DEST="${dest_input:-$DEFAULT_DEST}"
else
    DEST="$DEFAULT_DEST"
fi

# Expansão de ~
DEST="${DEST/#\~/$HOME}"

if [ -d "$DEST" ]; then
    if [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
        destrave_warn "$DEST já existe e não está vazio."
        if [ -t 0 ]; then
            printf "Sobrescrever arquivos do template? (s/N) "
            read -r overwrite
            if [ "$overwrite" != "s" ] && [ "$overwrite" != "S" ]; then
                destrave_info "Mantendo o que já existe. Vou só preencher o que faltar."
                FORCE=false
            else
                FORCE=true
            fi
        else
            FORCE=false
        fi
    else
        FORCE=true
    fi
else
    mkdir -p "$DEST"
    FORCE=true
fi

# --- Cópia idempotente ------------------------------------------------------
# Copia arquivos do template preservando o que o mentorado já tiver
copy_if_missing() {
    local rel="$1"
    local src="$TEMPLATE_DIR/$rel"
    local dst="$DEST/$rel"

    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ "$FORCE" != true ]; then
        return 0
    fi
    cp "$src" "$dst"
}

# Itera todos os arquivos do template (inclui .gitkeep)
while IFS= read -r -d '' file; do
    rel="${file#"$TEMPLATE_DIR/"}"
    copy_if_missing "$rel"
done < <(find "$TEMPLATE_DIR" -type f -print0)

destrave_ok "Wiki criada em $DEST"
echo ""
echo "  Estrutura:"
echo "    _schema.md    — regras pro LLM manter a wiki"
echo "    index.md      — mapa principal"
echo "    log.md        — log append-only de operações"
echo "    clientes/     — uma página por cliente"
echo "    padroes/      — processos repetíveis"
echo "    decisoes/     — ADRs"
echo "    projetos/     — seus projetos próprios"
echo "    _fontes/      — raw sources (transcrições, dossiês)"
echo ""
destrave_info "Aponte o Obsidian pra essa pasta pra navegar o grafo."
