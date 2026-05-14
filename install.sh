#!/usr/bin/env bash
# install.sh — Master interativo do Destrave Starter Kit
# Mac, Linux nativo e WSL2 Ubuntu rodam o mesmo script.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/detect-os.sh
source "$SCRIPT_DIR/lib/detect-os.sh"

# -- Skills disponíveis ------------------------------------------------------
# Skills no master "tudo" (a). MemPalace é opt-in (opção 6 explícita, fora do "a").
declare -a SKILL_KEYS=(terminal rtk dictation agent-browser wiki-template done)
declare -A SKILL_LABELS=(
    [terminal]="Fase 0 · Terminal (ZSH + Oh My Zsh)"
    [rtk]="RTK (token optimizer)"
    [dictation]="Dictation (Whispering)"
    [agent-browser]="agent-browser"
    [wiki-template]="Wiki template"
    [done]="/done (ritual de fim)"
    [mempalace]="MemPalace (avançado, opt-in)"
)
declare -A SKILL_SCRIPTS=(
    [terminal]="$SCRIPT_DIR/terminal/install-mac-linux.sh"
    [rtk]="$SCRIPT_DIR/skills/rtk/install-mac-linux.sh"
    [dictation]="$SCRIPT_DIR/skills/dictation/install-mac-linux.sh"
    [agent-browser]="$SCRIPT_DIR/skills/agent-browser/install-mac-linux.sh"
    [wiki-template]="$SCRIPT_DIR/skills/wiki-template/install-mac-linux.sh"
    [done]="$SCRIPT_DIR/skills/done/install-mac-linux.sh"
    [mempalace]="$SCRIPT_DIR/skills/mempalace/install-mac-linux.sh"
)

declare -A SKILL_STATUS

run_skill() {
    local key="$1"
    local script="${SKILL_SCRIPTS[$key]}"
    local label="${SKILL_LABELS[$key]}"

    destrave_section ">>> $label"

    if [ ! -x "$script" ]; then
        chmod +x "$script" 2>/dev/null || true
    fi

    if bash "$script"; then
        SKILL_STATUS[$key]="ok"
        destrave_ok "$label · concluído"
    else
        SKILL_STATUS[$key]="fail"
        destrave_err "$label · falhou (exit $?)"
    fi
}

# -- Pre-flight --------------------------------------------------------------
destrave_section "Destrave Starter Kit · Instalação"
destrave_info "SO detectado: $DESTRAVE_OS · pkg manager: $DESTRAVE_PKG_MANAGER · arch: $DESTRAVE_ARCH"

if [ "$DESTRAVE_OS" = "unknown" ]; then
    destrave_err "Não consegui detectar o SO. Abortando."
    exit 1
fi

# Mac sem brew → barra cedo (vários installers dependem dele)
if [ "$DESTRAVE_OS" = "mac" ] && [ "$DESTRAVE_PKG_MANAGER" != "brew" ]; then
    destrave_err "Homebrew não encontrado. Instale: https://brew.sh — depois rode de novo."
    exit 1
fi

# Linux/WSL precisam de pkg manager conhecido
if { [ "$DESTRAVE_OS" = "linux" ] || [ "$DESTRAVE_OS" = "wsl" ]; } && [ "$DESTRAVE_PKG_MANAGER" = "unknown" ]; then
    destrave_err "Nenhum pkg manager reconhecido (apt/dnf/pacman). Abra issue no repo."
    exit 1
fi

# -- Menu --------------------------------------------------------------------
echo ""
echo "  [0] ${SKILL_LABELS[terminal]}"
echo ""
echo "  Skills core:"
echo "  [1] ${SKILL_LABELS[rtk]}"
echo "  [2] ${SKILL_LABELS[dictation]}"
echo "  [3] ${SKILL_LABELS[agent-browser]}"
echo "  [4] ${SKILL_LABELS[wiki-template]}"
echo "  [5] ${SKILL_LABELS[done]}"
echo ""
echo "  Avançada (opt-in, FORA do 'a'):"
echo "  [6] ${SKILL_LABELS[mempalace]}"
echo ""
echo "  (a) Tudo — Fase 0 + skills 1-5    (b) Escolher um a um    (c) Sair"
echo ""
printf "> "
read -r choice

run_all() {
    for key in "${SKILL_KEYS[@]}"; do
        run_skill "$key"
    done
}

run_choose() {
    for key in "${SKILL_KEYS[@]}"; do
        printf "Instalar %s? (s/N) " "${SKILL_LABELS[$key]}"
        read -r resp
        if [ "$resp" = "s" ] || [ "$resp" = "S" ]; then
            run_skill "$key"
        else
            SKILL_STATUS[$key]="skip"
        fi
    done
}

case "$choice" in
    a|A)  run_all ;;
    b|B)  run_choose ;;
    c|C)  destrave_info "Saindo."; exit 0 ;;
    0)    run_skill "terminal" ;;
    1)    run_skill "rtk" ;;
    2)    run_skill "dictation" ;;
    3)    run_skill "agent-browser" ;;
    4)    run_skill "wiki-template" ;;
    5)    run_skill "done" ;;
    6)    run_skill "mempalace" ;;
    *)    destrave_err "Opção inválida: $choice"; exit 1 ;;
esac

# -- Resumo final ------------------------------------------------------------
echo ""
destrave_section "Resumo"
for key in "${SKILL_KEYS[@]}"; do
    status="${SKILL_STATUS[$key]:-}"
    case "$status" in
        ok)   printf "  \033[1;32m✓\033[0m  %s\n" "${SKILL_LABELS[$key]}" ;;
        fail) printf "  \033[1;31m✗\033[0m  %s (verifique log acima)\n" "${SKILL_LABELS[$key]}" ;;
        skip) printf "  \033[1;33m-\033[0m  %s (pulado)\n" "${SKILL_LABELS[$key]}" ;;
        *)    ;;
    esac
done
echo ""
destrave_info "Próximo: abra um terminal novo (pra ZSH/OMZ ativarem) e teste 'rtk gain'."
destrave_info "Doc completa: README.md na raiz do repo."
