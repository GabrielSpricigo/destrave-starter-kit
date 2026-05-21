# Destrave Starter Kit

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20Windows%20(WSL2)-blue)
![Made by Gabriel Pedrozo](https://img.shields.io/badge/by-Gabriel%20Pedrozo-orange)

Repositório plug-and-play para mentorados do **Destrave Claude Code** subirem
o ambiente em 10–15 minutos. Um comando instala terminal produtivo + skills
core do Claude Code, no Mac, Linux ou Windows.

> Versão 2 — substitui o PDF de prompts da v1 por instaladores automatizados.
> O PDF original continua em `docs/starter-kit-v1-prompts.pdf` para histórico.

---

## O que você ganha

**Fase 0 — Terminal**
- Mac/Linux/WSL: ZSH + Oh My Zsh + plugins (autosuggestions, syntax-highlighting)
- Windows: usa o mesmo ZSH+OMZ via WSL2 + Ubuntu (instalado pelo `install.ps1`)

**Skills core (5)**
1. **RTK** — token optimization (60–90% economia em comandos de dev)
2. **Dictation** — ditar com a voz dentro do Claude Code (alternativa cross-platform ao OpenWispr)
3. **agent-browser** — CLI padrão de navegação web para agentes
4. **Wiki template** — segundo cérebro mínimo (clientes, padrões, decisões, projetos). Skill derivada do [LLM-Wiki-Skilled](https://github.com/TrueHOOHA/LLM-Wiki-Skilled) (TrueHOOHA).
5. **/done** — ritual de fim de sessão com calibração de skills

**Opt-in (avançado)**
- **MemPalace** — memória semântica persistente entre conversas (requer Python + ChromaDB)

---

## Pré-requisitos

| OS       | O que precisa estar instalado antes |
|----------|--------------------------------------|
| **Mac**     | [Homebrew](https://brew.sh), `git`, Claude Code |
| **Linux**   | `git`, `curl`, Claude Code |
| **Windows** | Windows 10 versão 2004+ ou Windows 11 (qualquer build moderno), `git` no Windows |

> Não tem Claude Code ainda? Veja [claude.com/code](https://claude.com/code).

> **Windows usa WSL2 + Ubuntu.** O ZSH e o Oh My Zsh que aparecem na aula são shells Unix —
> não rodam em PowerShell puro. O kit instala o WSL pra você (um comando, um reboot) e
> roda exatamente o mesmo `install.sh` que o Mac usa, dentro do Ubuntu. Resultado: o que
> você vê na aula é o que aparece na sua tela.

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

### Windows (PowerShell como Administrador)

**Passo 1** — instalar WSL2 + Ubuntu (uma vez só, pede reboot):

```powershell
git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git $HOME\destrave-starter-kit
cd $HOME\destrave-starter-kit
.\install.ps1
```

**Passo 2** — depois do reboot, abra **Ubuntu** no menu Iniciar e rode:

```bash
git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git ~/destrave-starter-kit
cd ~/destrave-starter-kit
bash install.sh
```

A partir daí, o caminho Windows é idêntico ao Linux. Toda a aula faz sentido sem adaptação.

O master abre um menu. Escolha `(a) Tudo` na primeira vez.

---

## O que cada skill faz

Documento ilustrado: [`docs/por-que-cada-skill-existe.pdf`](docs/por-que-cada-skill-existe.pdf)

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
└── docs/                         PDFs explicativos
```

---

## Autor

Construído por **[Gabriel Pedrozo](https://gabrielpedrozo.com)** — Drop Studios.

Mentor de empresários e profissionais que querem usar Claude Code (e agentes
de IA em geral) como vantagem competitiva real, não como brinquedo.

- 🌐 Site: [gabrielpedrozo.com](https://gabrielpedrozo.com)
- 📸 Instagram: [@ogabrielpedrozo](https://instagram.com/ogabrielpedrozo)
- 💼 LinkedIn: [in/ogabrielspricigo](https://linkedin.com/in/ogabrielspricigo)

> Mentorados Destrave: bug report direto via WhatsApp.
> Demais: [abra issue no repo](https://github.com/GabrielSpricigo/destrave-starter-kit/issues).

## Créditos

Este kit empacota e adapta projetos open-source incríveis:

- **[LLM-Wiki-Skilled](https://github.com/TrueHOOHA/LLM-Wiki-Skilled)** (TrueHOOHA) — base do template de wiki Karpathy-style.
- **[RTK · Rust Token Killer](https://github.com/rtk-ai/rtk)** — proxy CLI que economiza tokens.
- **[Whispering](https://github.com/braden-w/whispering)** (Braden Wong) — dictation cross-platform.
- **[agent-browser](https://www.npmjs.com/package/@vercel-labs/agent-browser)** (Vercel Labs) — CLI de navegação web.
- **[Oh My Zsh](https://ohmyz.sh)** — framework do shell ZSH.

## Licença

[MIT](LICENSE) — uso livre, comercial inclusive. Atribuição apreciada mas não exigida.
