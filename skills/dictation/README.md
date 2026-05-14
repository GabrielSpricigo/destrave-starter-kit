# Skill · Dictation (ditar com a voz)

Substitui o **OpenWispr** (que era Mac-only) por uma alternativa cross-platform:
**[Whispering](https://whispering.bradenwong.com)**.

## Por que Whispering

- Open-source, mantido ([github.com/braden-w/whispering](https://github.com/braden-w/whispering))
- **Mac, Windows e Linux** (Electron app)
- **Hotkey-driven** (mesma UX do OpenWispr: aperta, fala, solta, cola)
- Suporta **Whisper local** (privado, sem nuvem) ou **OpenAI API** (mais rápido)
- Cola onde o cursor estiver — incluindo dentro do Claude Code no terminal

Critério de escolha: UX próxima do OpenWispr + multi-OS + open-source.
Alternativas avaliadas: WisprFlow (pago), Vibe (sem hotkey), Talon (curva alta).

## Instalação

### Mac

```bash
bash install-mac-linux.sh
```

Instala via Homebrew Cask: `brew install --cask whispering`.

### Windows (no host, NÃO dentro do WSL)

Áudio + hotkey precisam rodar fora do WSL. Baixe e instale o `.exe` direto:

1. Abra [whispering.bradenwong.com](https://whispering.bradenwong.com)
2. Baixe o instalador Windows (`.exe`)
3. Instale como qualquer aplicativo Windows
4. Abra o Whispering, defina a hotkey (padrão: F10) e o backend (OpenAI ou Whisper local)

A dictation cola texto onde o cursor estiver — inclusive na janela do **Ubuntu (WSL)**
rodando Claude Code. Funciona como Mac.

### Linux nativo

```bash
bash install-mac-linux.sh
```

Tenta `flatpak install` ou baixa AppImage. Se nada funcionar, baixe manual em
[whispering.bradenwong.com](https://whispering.bradenwong.com).

## Setup do microfone

Na primeira execução, Whispering pede:
- **Acesso ao microfone** (System Settings > Privacy > Microphone no Mac)
- **Acesso de acessibilidade** (pra colar onde o cursor estiver)
- **Hotkey** (padrão F10 — pode mudar)
- **Backend**:
  - **OpenAI API** — rápido, pago (~$0.006/min), precisa de chave em platform.openai.com
  - **Whisper local** — gratuito, modelo baixa na primeira execução, mais lento

## Atalho top

Segure a hotkey, fale, solte. Em ~1s o texto aparece onde seu cursor estiver.
Em sessão Claude Code: você dita o prompt em vez de digitar.
