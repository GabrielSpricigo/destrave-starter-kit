#!/usr/bin/env bash
# Fase 2.3 — agent-browser (Vercel Labs)
# CLI padrão de navegação web pra agentes Claude Code.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/detect-os.sh
source "$SCRIPT_DIR/../../lib/detect-os.sh"

destrave_section "Skill · agent-browser"

# --- 1. Garantir Node >= 20 -------------------------------------------------
need_node_install=false
if ! command -v node >/dev/null 2>&1; then
    need_node_install=true
else
    NODE_MAJOR=$(node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1)
    if [ -z "$NODE_MAJOR" ] || [ "$NODE_MAJOR" -lt 20 ]; then
        destrave_warn "Node $(node -v) detectado, mas precisamos >= 20."
        need_node_install=true
    fi
fi

if [ "$need_node_install" = true ]; then
    destrave_info "Instalando Node 20 LTS..."
    case "$DESTRAVE_PKG_MANAGER" in
        brew)
            brew install node@20
            brew link --overwrite --force node@20 2>/dev/null || true
            ;;
        apt)
            # NodeSource setup script
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        dnf)
            curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
            sudo dnf install -y nodejs
            ;;
        pacman)
            sudo pacman -S --noconfirm nodejs npm
            ;;
        *)
            destrave_err "Instale Node 20+ manualmente: https://nodejs.org"
            exit 1
            ;;
    esac
fi

destrave_ok "Node: $(node -v) · npm: $(npm -v)"

# --- 2. Instalar agent-browser globalmente ----------------------------------
if command -v agent-browser >/dev/null 2>&1; then
    destrave_ok "agent-browser já instalado: $(agent-browser --version 2>&1 | head -1)"
else
    destrave_info "Instalando agent-browser..."
    if ! npm install -g agent-browser; then
        destrave_err "npm não conseguiu instalar o agent-browser."
        destrave_info "Tente na mão: npm install -g agent-browser"
        exit 1
    fi
    if command -v agent-browser >/dev/null 2>&1; then
        destrave_ok "agent-browser instalado: $(agent-browser --version 2>&1 | head -1)"
    else
        destrave_err "npm terminou sem erro, mas 'agent-browser' não está no PATH."
        destrave_info "Abra um terminal novo e rode de novo. Se persistir: npm prefix -g"
        exit 1
    fi
fi

# --- 3. Registrar uso preferencial no CLAUDE.md global ----------------------
CLAUDE_MD="$DESTRAVE_CLAUDE_DIR/CLAUDE.md"
mkdir -p "$DESTRAVE_CLAUDE_DIR"

MARKER="<!-- destrave-starter-kit:agent-browser -->"
if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
    destrave_ok "Regra agent-browser já presente em $CLAUDE_MD"
else
    {
        echo ""
        echo "$MARKER"
        echo "## Navegação web"
        echo ""
        echo "Quando precisar abrir um site, ler conteúdo da web, tirar screenshot ou interagir com UI:"
        echo "use \`agent-browser\` (CLI Vercel Labs)."
        echo ""
        echo "Hierarquia: API oficial > \`agent-browser\` > playwright > puppeteer."
        echo ""
        echo "Comando útil: \`agent-browser snapshot <url>\` devolve uma árvore com refs \`@eN\`"
        echo "(LLM-friendly). \`agent-browser click @e5\`, \`agent-browser type @e3 \"texto\"\`."
        echo ""
    } >> "$CLAUDE_MD"
    destrave_ok "Regra agent-browser adicionada a $CLAUDE_MD"
fi

destrave_section "agent-browser pronto"
destrave_info "Teste: agent-browser snapshot https://example.com"
