# Fase 0 · Terminal stack

Antes das skills, ajeitamos o terminal. Razão simples: você vai passar muitas
horas dentro dele. Um terminal lento, sem autocomplete e sem syntax highlight
é fricção que se paga em todas as sessões seguintes.

## O que esta fase faz

**Em Mac e Linux** — `terminal/install-mac-linux.sh`:

1. Instala `zsh` (se ainda não estiver).
2. Instala [Oh My Zsh](https://ohmyz.sh) preservando seu `.zshrc` se já existir.
3. Clona os 2 plugins essenciais em `~/.oh-my-zsh/custom/plugins/`:
   - `zsh-autosuggestions` — sugere o resto do comando baseado no histórico (aceitar com →)
   - `zsh-syntax-highlighting` — vermelho/verde antes de você apertar Enter
4. Edita seu `.zshrc` ativando os plugins (idempotente, faz backup em `.zshrc.destrave-backup`).
5. Torna `zsh` o shell padrão do seu usuário.

**Em Windows** — `terminal/install-windows.ps1`, tudo via `winget`, sem
Administrador e sem reboot:

1. Instala o **PowerShell 7**. O PowerShell que já vem no Windows é a versão
   5.1, cujo PSReadLine (2.0) é anterior ao autocomplete preditivo — é por isso
   que o terminal padrão do Windows parece pobre. O 7 traz o PSReadLine 2.4.
2. Instala o [Oh My Posh](https://ohmyposh.dev) e o tema `robbyrussell`, que é
   **o mesmo tema** que o Oh My Zsh usa na aula. O prompt fica igual.
3. Instala o perfil (`pwsh-profile.ps1`) no `$PROFILE` do seu usuário, com
   backup do anterior em `.destrave-backup`.

O resultado é equivalente: sugestão em cinza enquanto você digita, `Tab` com
menu de opções, busca no histórico pelas setas, prompt com pasta e branch.

> O tema vai versionado aqui no repo (`robbyrussell.omp.json`) de propósito: o
> Oh My Posh instalado pelo winget não traz a pasta de temas junto.

## Atalhos que valem ouro

Funcionam nos dois mundos:

| Tecla | O que faz |
|-------|-----------|
| ↑ | Histórico (digite um pedaço antes pra filtrar) |
| → | Aceita a sugestão em cinza |
| Tab | Autocomplete de arquivos, comandos, branches git |
| Ctrl+R | Busca reversa no histórico |
| Ctrl+A / Ctrl+E | Início / fim da linha |
| Ctrl+U / Ctrl+K | Apaga até o início / fim |
| Ctrl+W | Apaga uma palavra pra trás |
| `cd -` | Volta pro diretório anterior |

Só no Windows: **F2** alterna a sugestão entre linha única e lista de opções.

Só no Unix: `!!` reexecuta o último comando (`sudo !!` é clássico).

## Tema

**Mac/Linux:** default `robbyrussell` — minimalista e estável. Outras boas
opções: `agnoster`, `gnzh`, `bira`. Edite `ZSH_THEME=` no seu `~/.zshrc`.

**Windows:** default `robbyrussell` também. Para trocar, veja os
[temas do Oh My Posh](https://ohmyposh.dev/docs/themes) e ajuste o caminho no
`--config` dentro do seu `$PROFILE`.

Temas mais elaborados (como `agnoster`) precisam de **Nerd Font** pra renderizar
os glifos. [Cascadia Code NF](https://github.com/microsoft/cascadia-code) é uma
boa. O `robbyrussell` não precisa — foi um dos motivos de ser o default.

## Troubleshooting

**"Permission denied" no chsh (Mac/Linux)** — rode `chsh -s "$(which zsh)"`
manualmente.

**Plugins não funcionam (Mac/Linux)** — o script edita `.zshrc`, mas se você
abrir um terminal ainda em bash, o efeito não aparece. Feche e abra um terminal
novo ou rode `exec zsh`.

**A sugestão em cinza não aparece (Windows)** — confirme que está no PowerShell
7 (comando `pwsh`) e não no 5.1. No Windows Terminal: Configurações > Perfil
padrão > PowerShell 7.

**O instalador disse que gravou o perfil, mas nada mudou (Windows)** — é o
**Acesso Controlado a Pastas** do Windows Defender bloqueando gravação em
Documentos sem gerar erro. O instalador detecta e avisa, gravando num caminho
alternativo. Para liberar de vez, no PowerShell como Administrador:
`Set-MpPreference -EnableControlledFolderAccess Disabled`

**Backup do arquivo original** — Mac/Linux em `~/.zshrc.destrave-backup`;
Windows em `<caminho do $PROFILE>.destrave-backup`. Para restaurar, renomeie
por cima do original.
