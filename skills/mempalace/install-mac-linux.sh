#!/usr/bin/env bash
# Fase 4 — MemPalace (opt-in)
# Instala o pacote pip 'mempalace' e imprime o snippet de .mcp.json pra colar.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/detect-os.sh
source "$SCRIPT_DIR/../../lib/detect-os.sh"

destrave_section "Skill · MemPalace (opt-in)"
destrave_warn "Avançado. Pule se está começando — wiki resolve 80% do problema."

# --- 1. Python 3.10+ --------------------------------------------------------
PYTHON_BIN=""
for cand in python3.12 python3.11 python3.10 python3; do
    if command -v "$cand" >/dev/null 2>&1; then
        v=$("$cand" -c "import sys; print(sys.version_info[0]*100+sys.version_info[1])" 2>/dev/null || echo 0)
        if [ "$v" -ge 310 ]; then
            PYTHON_BIN=$(command -v "$cand")
            break
        fi
    fi
done

if [ -z "$PYTHON_BIN" ]; then
    destrave_err "Python 3.10+ não encontrado."
    case "$DESTRAVE_PKG_MANAGER" in
        brew) destrave_info "Instale: brew install python@3.12" ;;
        apt)  destrave_info "Instale: sudo apt-get install python3 python3-pip python3-venv" ;;
        *)    destrave_info "Instale Python 3.10+ pelo seu pkg manager." ;;
    esac
    exit 1
fi
destrave_ok "Python: $PYTHON_BIN ($($PYTHON_BIN --version))"

# --- 2. Instalar mempalace --------------------------------------------------
if "$PYTHON_BIN" -m pip show mempalace >/dev/null 2>&1; then
    VERSION=$("$PYTHON_BIN" -m pip show mempalace | awk '/^Version:/ {print $2}')
    destrave_ok "mempalace já instalado (v$VERSION)"
else
    destrave_info "Instalando mempalace via pip (pode demorar 1-3min — chromadb tem várias deps)..."
    "$PYTHON_BIN" -m pip install --user --upgrade mempalace
    destrave_ok "mempalace instalado."
fi

# --- 3. Snippet pra .mcp.json -----------------------------------------------
PROJECT_DEFAULT="$PWD"
if [ -t 0 ]; then
    echo ""
    printf "Qual é a raiz do seu projeto? [%s] " "$PROJECT_DEFAULT"
    read -r project_input
    PROJECT="${project_input:-$PROJECT_DEFAULT}"
else
    PROJECT="$PROJECT_DEFAULT"
fi
PROJECT="${PROJECT/#\~/$HOME}"

destrave_section "Configuração — cole isso no .mcp.json do seu projeto"
echo ""
cat <<EOF
{
  "mcpServers": {
    "mempalace": {
      "command": "$PYTHON_BIN",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_DIR": "$PROJECT"
      }
    }
  }
}
EOF
echo ""

# --- 4. Oferecer gravar automaticamente -------------------------------------
MCP_FILE="$PROJECT/.mcp.json"
if [ -t 0 ]; then
    printf "Quer que eu grave isso em %s agora? (s/N) " "$MCP_FILE"
    read -r resp
    if [ "$resp" = "s" ] || [ "$resp" = "S" ]; then
        if [ -f "$MCP_FILE" ]; then
            destrave_warn "$MCP_FILE já existe."
            if command -v jq >/dev/null 2>&1; then
                cp "$MCP_FILE" "${MCP_FILE}.destrave-backup"
                TMP=$(mktemp)
                jq --arg cmd "$PYTHON_BIN" --arg dir "$PROJECT" '
                    .mcpServers //= {}
                    | .mcpServers.mempalace = {
                        "command": $cmd,
                        "args": ["-m", "mempalace.mcp_server"],
                        "env": {"MEMPALACE_DIR": $dir}
                      }
                ' "$MCP_FILE" > "$TMP"
                mv "$TMP" "$MCP_FILE"
                destrave_ok "$MCP_FILE atualizado (backup em ${MCP_FILE}.destrave-backup)"
            else
                destrave_err "jq não disponível — não dá pra fazer merge seguro. Cole manualmente."
            fi
        else
            mkdir -p "$PROJECT"
            cat > "$MCP_FILE" <<EOF
{
  "mcpServers": {
    "mempalace": {
      "command": "$PYTHON_BIN",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_DIR": "$PROJECT"
      }
    }
  }
}
EOF
            destrave_ok "$MCP_FILE criado."
        fi
    fi
fi

destrave_section "Próximos passos"
echo "  1. Reinicie o Claude Code."
echo "  2. Em qualquer sessão dentro de $PROJECT, teste: 'rode mempalace_status'."
echo "  3. Comece a gravar triples — leia README.md desta skill antes."
