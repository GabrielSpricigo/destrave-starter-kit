#!/usr/bin/env bash
# Fase 0 — Terminal: ZSH + Oh My Zsh + plugins
#
# Idempotente: pode rodar quantas vezes quiser, só preenche o que faltar.
# Funciona em Mac, Linux nativo e WSL2 Ubuntu.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/detect-os.sh
source "$SCRIPT_DIR/../lib/detect-os.sh"

destrave_section "Fase 0 · Terminal stack (ZSH + Oh My Zsh)"
destrave_info "SO detectado: $DESTRAVE_OS · pkg manager: $DESTRAVE_PKG_MANAGER"

# --- 1. Instalar zsh --------------------------------------------------------
if command -v zsh >/dev/null 2>&1; then
    destrave_ok "zsh já instalado: $(zsh --version)"
else
    destrave_info "Instalando zsh..."
    case "$DESTRAVE_PKG_MANAGER" in
        brew)
            brew install zsh
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y zsh
            ;;
        dnf)
            sudo dnf install -y zsh
            ;;
        pacman)
            sudo pacman -S --noconfirm zsh
            ;;
        *)
            destrave_err "Pkg manager não reconhecido. Instale zsh manualmente e rode de novo."
            exit 1
            ;;
    esac
    destrave_ok "zsh instalado."
fi

# --- 2. Instalar Oh My Zsh --------------------------------------------------
OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"

if [ -d "$OMZ_DIR" ]; then
    destrave_ok "Oh My Zsh já instalado em $OMZ_DIR"
else
    destrave_info "Instalando Oh My Zsh..."
    # KEEP_ZSHRC=yes preserva .zshrc existente, RUNZSH=no evita abrir subshell no fim,
    # CHSH=no não muda o shell padrão aqui (fazemos isso manualmente abaixo)
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    destrave_ok "Oh My Zsh instalado."
fi

# --- 3. Plugins: autosuggestions + syntax-highlighting ----------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"

clone_plugin() {
    local name="$1"
    local url="$2"
    local target="$ZSH_CUSTOM/plugins/$name"

    if [ -d "$target" ]; then
        destrave_ok "Plugin $name já presente."
    else
        destrave_info "Clonando plugin $name..."
        git clone --depth=1 "$url" "$target" >/dev/null 2>&1
        destrave_ok "Plugin $name instalado."
    fi
}

clone_plugin "zsh-autosuggestions"      "https://github.com/zsh-users/zsh-autosuggestions"
clone_plugin "zsh-syntax-highlighting"  "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# --- 4. Patch .zshrc (adiciona plugins se ainda não estão) ------------------
ZSHRC="$HOME/.zshrc"

if [ ! -f "$ZSHRC" ]; then
    destrave_warn ".zshrc não existe. Criando um mínimo."
    cat > "$ZSHRC" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
EOF
fi

# Faz backup uma vez
if [ ! -f "$ZSHRC.destrave-backup" ]; then
    cp "$ZSHRC" "$ZSHRC.destrave-backup"
    destrave_info "Backup do .zshrc salvo em $ZSHRC.destrave-backup"
fi

# Patch da linha plugins=(...)
if grep -qE '^plugins=\(' "$ZSHRC"; then
    # Adiciona plugins faltantes, preservando os existentes
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if grep -qE "^plugins=\([^)]*\b$plugin\b" "$ZSHRC"; then
            destrave_ok ".zshrc já tem $plugin."
        else
            # Insere antes do `)` final na linha plugins=(
            # Compatível com sed BSD (Mac) e GNU (Linux)
            if [ "$DESTRAVE_OS" = "mac" ]; then
                sed -i '' "s/^plugins=(\(.*\))/plugins=(\1 $plugin)/" "$ZSHRC"
            else
                sed -i "s/^plugins=(\(.*\))/plugins=(\1 $plugin)/" "$ZSHRC"
            fi
            destrave_ok "Adicionado $plugin ao .zshrc."
        fi
    done
else
    destrave_warn "Linha 'plugins=(...)' não encontrada no .zshrc. Adicionando uma."
    printf '\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\n' >> "$ZSHRC"
fi

# --- 5. Tema padrão (sugere agnoster se ainda for default) ------------------
if grep -qE '^ZSH_THEME="robbyrussell"' "$ZSHRC"; then
    destrave_info "Tema atual: robbyrussell (default OMZ — bom o suficiente)."
    destrave_info "Pra trocar: edite ZSH_THEME no $ZSHRC. Sugestões: agnoster, gnzh, bira."
fi

# --- 6. Tornar zsh o shell padrão -------------------------------------------
ZSH_BIN="$(command -v zsh)"
if [ "${SHELL:-}" != "$ZSH_BIN" ]; then
    destrave_info "Shell atual: ${SHELL:-?}. Tornando zsh padrão..."
    if [ "$DESTRAVE_OS" = "mac" ]; then
        # Mac: zsh já costuma ser default desde Catalina, mas garantimos
        if ! grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null; then
            echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
        fi
        chsh -s "$ZSH_BIN" || destrave_warn "chsh falhou — rode manualmente: chsh -s $ZSH_BIN"
    else
        # Linux/WSL
        sudo chsh -s "$ZSH_BIN" "$USER" || destrave_warn "chsh falhou — rode manualmente: chsh -s $ZSH_BIN"
    fi
    destrave_ok "Shell padrão configurado pra zsh (efetiva no próximo terminal)."
else
    destrave_ok "zsh já é o shell padrão."
fi

# --- Resumo final -----------------------------------------------------------
destrave_section "Fase 0 concluída"
echo "  · zsh: $(zsh --version)"
echo "  · Oh My Zsh: $OMZ_DIR"
echo "  · Plugins: zsh-autosuggestions, zsh-syntax-highlighting"
echo "  · .zshrc: $ZSHRC (backup em ${ZSHRC}.destrave-backup)"
echo ""
destrave_info "Abra um novo terminal pra ver o resultado."
destrave_info "Atalhos top: ↑ (histórico fuzzy), → (aceitar sugestão), Tab (autocomplete)."
