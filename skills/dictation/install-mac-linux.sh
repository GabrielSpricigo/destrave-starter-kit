#!/usr/bin/env bash
# Fase 2.2 — Dictation (Whispering, substituto cross-platform do OpenWispr)
#
# Mac: brew cask
# Linux nativo: flatpak ou AppImage
# WSL: NÃO roda dictation dentro do WSL (sem acesso a mic/cursor do host).
#      Mentorado precisa instalar o app Windows direto. Mostramos a URL.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/detect-os.sh
source "$SCRIPT_DIR/../../lib/detect-os.sh"

destrave_section "Skill · Dictation (Whispering)"

case "$DESTRAVE_OS" in
    mac)
        if [ "$DESTRAVE_PKG_MANAGER" != "brew" ]; then
            destrave_err "Homebrew não detectado. Instale: https://brew.sh"
            exit 1
        fi
        if brew list --cask whispering >/dev/null 2>&1; then
            destrave_ok "Whispering já instalado."
        else
            destrave_info "Instalando Whispering via brew cask..."
            brew install --cask whispering
            destrave_ok "Whispering instalado em /Applications."
        fi
        destrave_info "Abra o app, conceda permissões (Mic + Accessibility) e defina a hotkey."
        ;;

    wsl)
        destrave_warn "Dictation precisa rodar no Windows host (não dentro do WSL)."
        echo ""
        echo "  1. No Windows, abra:  https://whispering.bradenwong.com"
        echo "  2. Baixe o instalador .exe e execute."
        echo "  3. Configure hotkey + backend (OpenAI API ou Whisper local)."
        echo ""
        destrave_info "Whispering cola texto onde o cursor estiver — funciona dentro do Ubuntu WSL."
        ;;

    linux)
        if command -v flatpak >/dev/null 2>&1; then
            destrave_info "Tentando instalar via Flatpak..."
            if flatpak install -y flathub com.bradenwong.Whispering 2>/dev/null; then
                destrave_ok "Whispering instalado via Flatpak."
                exit 0
            fi
        fi
        destrave_warn "Sem caminho automático limpo no Linux nativo no momento."
        echo ""
        echo "  Baixe manualmente em:  https://whispering.bradenwong.com"
        echo "  Ou github releases:     https://github.com/braden-w/whispering/releases"
        echo ""
        destrave_info "Procure o .AppImage ou .deb pra sua distro."
        ;;

    *)
        destrave_err "OS não suportado: $DESTRAVE_OS"
        exit 1
        ;;
esac
