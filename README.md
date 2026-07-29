# Destrave Starter Kit

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20Windows-blue)
![Made by Gabriel Pedrozo](https://img.shields.io/badge/by-Gabriel%20Pedrozo-orange)

Repositório plug-and-play para mentorados do **Destrave Claude Code** subirem
o ambiente em 10–15 minutos. Um comando instala terminal produtivo + skills
core do Claude Code, no Mac, Linux ou Windows.

> Versão 2 — substitui o PDF de prompts da v1 por instaladores automatizados.
> O PDF original continua em `docs/starter-kit-v1-prompts.pdf` para histórico.

---

## 🤝 Quer ajuda para instalar? Peça para o Claude

Você não precisa entender de terminal. Abra o Claude, **cole o link deste
repositório** e escreva:

> *Me ajuda a instalar isso na minha máquina? Não sou técnico, então vai me
> explicando o que está acontecendo.*

Ele lê as instruções que estão aqui e conduz a instalação com você.
Se preferir um texto pronto e mais detalhado para colar, use o
[INSTALAR-PELO-CLAUDE.md](INSTALAR-PELO-CLAUDE.md).

<a id="para-agentes"></a>

### 🤖 Instruções para o assistente de IA que estiver lendo isto

**Roteiro completo: [CLAUDE.md](https://github.com/GabrielSpricigo/destrave-starter-kit/blob/main/CLAUDE.md)** — leia antes de agir.
O essencial, caso você não consiga abrir outro arquivo:

1. **Descubra se você pode executar comandos.** Se puder (Claude Code),
   conduza a instalação. Se você só conversa (navegador), entregue os comandos
   para a pessoa colar e interprete o que ela responder — e diga isso a ela.
2. **Descubra o sistema operacional** antes de qualquer comando. Não presuma.
3. **Rode o instalador.** Windows, em PowerShell comum (sem Administrador):
   `powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/GabrielSpricigo/destrave-starter-kit/main/bootstrap.ps1 | iex"`
   Mac/Linux: `git clone` deste repo e `bash install.sh`. No menu, escolha `a`.
4. **Verifique em disco.** Não conclua que funcionou porque o instalador disse
   que funcionou — no Windows existe uma falha em que a gravação reporta
   sucesso e o arquivo não existe (Acesso Controlado a Pastas do Defender).
   Confirme: `rtk gain` responde, `~/.claude/settings.json` tem
   `rtk hook claude`, e o perfil do terminal existe.

**Regras que evitam estrago:**

- **Nunca sugira WSL.** Foi removido do kit de propósito em 07/2026 — mesmo
  rodando dentro do Ubuntu, o Claude e o RTK executavam do lado Windows. A
  instalação é nativa.
- **Nunca peça Administrador.** Não é necessário em nenhuma etapa.
- **Não invente comandos de outras fontes** nem instale nada além do kit.
- Rodar de novo é seguro: os instaladores são idempotentes.
- O público é **não-técnico** — explique sem jargão, um passo por vez.

---

## O que você ganha

**Fase 0 — Terminal**
- Mac/Linux: ZSH + Oh My Zsh + plugins (autosuggestions, syntax-highlighting)
- Windows: PowerShell 7 + PSReadLine (autocomplete) + Oh My Posh (prompt)

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
| **Windows** | Windows 10 versão 2004+ ou Windows 11, `winget` (vem com o "Instalador de Aplicativo" da Microsoft Store), Claude Code |

> Não tem Claude Code ainda? Veja [claude.com/code](https://claude.com/code).

> **No Windows não precisa de WSL, nem de Administrador, nem de reboot.**
> A instalação roda em PowerShell nativo com o seu usuário comum.

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

### Windows

Abra o **PowerShell** (o normal, sem "como administrador") e cole:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/GabrielSpricigo/destrave-starter-kit/main/bootstrap.ps1 | iex"
```

Esse comando baixa o kit e abre o instalador. Não precisa ter `git` instalado.

> **Não gosta de terminal?** Dá pra pedir para o próprio Claude Code fazer a
> instalação e te explicar cada passo: veja [INSTALAR-PELO-CLAUDE.md](INSTALAR-PELO-CLAUDE.md).

O master abre um menu. Escolha `(a) Tudo` na primeira vez.

---

## Windows: o que muda em relação à aula

A aula é gravada no Mac, com ZSH. No Windows você usa PowerShell. O prompt na
tela é **o mesmo tema** (`robbyrussell`) e os atalhos de teclado batem, então
o dia a dia é igual. O que muda são alguns comandos:

| Na aula (ZSH/Mac) | No seu Windows (PowerShell) | O que é |
|---|---|---|
| `~/.zshrc` | `$PROFILE` | arquivo de configuração do terminal |
| `ls -la` | `ll` | listar arquivos, inclusive ocultos |
| `which claude` | `Get-Command claude` | descobrir onde um programa está |
| `export VAR=valor` | `$env:VAR = "valor"` | criar variável de ambiente |
| `source arquivo` | `. arquivo` | carregar um script no terminal atual |
| `grep texto arquivo` | `Select-String texto arquivo` | procurar texto dentro de arquivo |
| `rm -rf pasta` | `Remove-Item -Recurse -Force pasta` | apagar pasta e conteúdo |
| `open .` | `ii .` | abrir a pasta atual no explorador |

Estes funcionam igual nos dois: `cd`, `pwd`, `cat`, `mkdir`, `cp`, `mv`,
`echo`, `curl`, `git`, `claude`, `rtk`, `Tab`, `Ctrl+R`, `Ctrl+C`, `↑`, `→`.

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

## Já tinha instalado pela versão antiga (com WSL)?

Até julho de 2026 o kit instalava WSL2 + Ubuntu no Windows. **Isso não é mais
necessário** — e, na prática, nunca entregou o que prometia: mesmo rodando
`claude` dentro do Ubuntu, quem executava era o Claude do Windows, gravando
tudo no perfil do Windows. O RTK idem. O WSL só somava uma camada de tradução
no meio, que é de onde vinham problemas como colar texto de forma errada.

Para migrar: rode o comando do Quickstart do Windows acima. Ele instala a
stack nativa direto.

Seu WSL continua instalado e funcionando — este kit só deixa de usá-lo. Se
você não usa o Ubuntu para mais nada e quiser remover, é
`wsl --unregister Ubuntu` (isso apaga os arquivos que estiverem lá dentro).

---

## Troubleshooting

**Windows: "não é possível carregar o arquivo... não está assinado digitalmente"**
É a política de execução de scripts do Windows. Use o comando do Quickstart,
que já vem com `-ExecutionPolicy Bypass`.

**Windows: o instalador diz que gravou, mas nada mudou**
Provavelmente é o **Acesso Controlado a Pastas** do Windows Defender, que
bloqueia gravação em Documentos sem gerar erro. O instalador detecta isso e
avisa na tela, seguindo por um caminho alternativo. Para liberar de vez, abra
o PowerShell como Administrador e rode:
`Set-MpPreference -EnableControlledFolderAccess Disabled`

**Windows: instalei mas o comando não existe**
Feche o terminal e abra um novo. A lista de programas do terminal só é lida
na abertura.

**Windows: a sugestão em cinza não aparece**
Confirme que você está no PowerShell 7 (comando `pwsh`), não no PowerShell 5.1
que vem com o Windows. No Windows Terminal: Configurações > Perfil padrão >
PowerShell 7.

Outros casos: abra issue no repo com OS + versão, comando que rodou e a
mensagem de erro completa.

---

## Estrutura do repo

```
destrave-starter-kit/
├── bootstrap.ps1                 Entrada de um comando só (Windows)
├── install.sh / install.ps1      Masters por OS (menu interativo)
├── INSTALAR-PELO-CLAUDE.md       Instalação conversando com o Claude Code
├── lib/                          Helpers de detecção de OS
├── terminal/                     Fase 0 — ZSH/OMZ (Unix) ou PowerShell 7 (Windows)
├── skills/                       5 skills core + MemPalace opt-in
│   ├── rtk/
│   ├── dictation/
│   ├── agent-browser/
│   ├── wiki-template/
│   ├── done/
│   └── mempalace/
└── docs/                         PDFs explicativos
```

Cada skill tem `install-mac-linux.sh` e `install-windows.ps1` — mesmo
resultado, caminhos diferentes.

> **Nota de encoding para quem for contribuir** — são duas regras opostas, e
> confundir uma com a outra quebra a instalação:
>
> - Todo `.ps1` **executado a partir do disco** precisa ser UTF-8 **com BOM**.
>   Sem o BOM, o Windows PowerShell 5.1 lê como ANSI e todo acento vira lixo
>   na tela ("instalação" → "instalaÃ§Ã£o").
> - **`bootstrap.ps1` é a exceção: sem BOM e somente ASCII.** Ele é consumido
>   por `irm | iex`, e nesse caminho o BOM chega como caractere invisível no
>   início da string e quebra o parser antes de qualquer linha rodar. Como
>   fica sem BOM, também não pode ter acentos.

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
- **[agent-browser](https://www.npmjs.com/package/agent-browser)** (Vercel Labs) — CLI de navegação web.
- **[Oh My Zsh](https://ohmyz.sh)** — framework do shell ZSH.
- **[Oh My Posh](https://ohmyposh.dev)** (Jan De Dobbeleer) — prompt para PowerShell.

## Licença

[MIT](LICENSE) — uso livre, comercial inclusive. Atribuição apreciada mas não exigida.
