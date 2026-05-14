# Destrave Starter Kit

Repositório plug-and-play para mentorados do **Destrave Claude Code** subirem
o ambiente em 10–15 minutos. Um comando instala terminal produtivo + skills
core do Claude Code, no Mac, Linux ou Windows.

> Versão 2 — substitui o PDF de prompts da v1 por instaladores automatizados.
> O PDF original continua em `docs/starter-kit-v1-prompts.html` para histórico.

---

## O que você ganha

**Fase 0 — Terminal**
- Mac/Linux: ZSH + Oh My Zsh + plugins (autosuggestions, syntax-highlighting)
- Windows: Windows Terminal + Oh My Posh + PSReadLine + Nerd Font

**Skills core (5)**
1. **RTK** — token optimization (60–90% economia em comandos de dev)
2. **Dictation** — ditar com a voz dentro do Claude Code (alternativa cross-platform ao OpenWispr)
3. **agent-browser** — CLI padrão de navegação web para agentes
4. **Wiki template** — segundo cérebro mínimo (clientes, padrões, decisões, projetos)
5. **/done** — ritual de fim de sessão com calibração de skills

**Opt-in (avançado)**
- **MemPalace** — memória semântica persistente entre conversas (requer Python + ChromaDB)

---

## Pré-requisitos

| OS       | O que precisa estar instalado antes |
|----------|--------------------------------------|
| **Mac**     | [Homebrew](https://brew.sh), `git`, Claude Code |
| **Linux**   | `git`, `curl`, `cargo` (ou `rustup`), Claude Code |
| **Windows** | [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) (Windows 10 1809+ ou 11), `git`, Claude Code |

> Não tem Claude Code ainda? Veja [claude.com/code](https://claude.com/code).

---

## Quickstart

### Mac

```bash
git clone git@github.com:GabrielSpricigo/destrave-starter-kit.git ~/destrave-starter-kit
cd ~/destrave-starter-kit
bash install.sh
```

### Linux

```bash
git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git ~/destrave-starter-kit
cd ~/destrave-starter-kit
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git $HOME\destrave-starter-kit
cd $HOME\destrave-starter-kit
.\install.ps1
```

O master abre um menu. Escolha `(a) Tudo` na primeira vez.

---

## O que cada skill faz

Documento ilustrado: [`docs/por-que-cada-skill-existe.html`](docs/por-que-cada-skill-existe.html)
(também disponível em PDF).

---

## Atualizar

```bash
cd ~/destrave-starter-kit
git pull
bash install.sh        # ou .\install.ps1 no Windows — reexecuta o que mudou
```

Os installers são idempotentes: rodar de novo não quebra nada nem reinstala
o que já está OK.

---

## Troubleshooting

A ser preenchido conforme aparecem casos reais (Mac, Linux, Windows).
Por ora, abra issue no repo com:
- OS + versão
- Comando que rodou
- Mensagem de erro completa

---

## Estrutura do repo

```
destrave-starter-kit/
├── install.sh / install.ps1     Masters por OS (menu interativo)
├── lib/                          Helpers de detecção de OS
├── terminal/                     Fase 0 — ZSH/OMZ ou Oh My Posh
├── skills/                       5 skills core + MemPalace opt-in
│   ├── rtk/
│   ├── dictation/
│   ├── agent-browser/
│   ├── wiki-template/
│   ├── done/
│   └── mempalace/
└── docs/                         HTML/PDFs explicativos
```

---

## Autor

[Gabriel Pedrozo](https://gabrielpedrozo.com) — Drop Studios.
Mentorados Destrave: bug report direto via WhatsApp.
