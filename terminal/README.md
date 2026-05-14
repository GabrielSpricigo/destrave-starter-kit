# Fase 0 · Terminal stack

Antes das skills, ajeitamos o terminal. Razão simples: você vai passar muitas
horas dentro dele. Um terminal lento, sem autocomplete e sem syntax highlight
é fricção que se paga em todas as sessões seguintes.

## O que esta fase faz

**Em Mac, Linux e WSL2 Ubuntu** — `terminal/install-mac-linux.sh`:

1. Instala `zsh` (se ainda não estiver).
2. Instala [Oh My Zsh](https://ohmyz.sh) preservando seu `.zshrc` se já existir.
3. Clona os 2 plugins essenciais em `~/.oh-my-zsh/custom/plugins/`:
   - `zsh-autosuggestions` — sugere o resto do comando baseado no histórico (aceitar com →)
   - `zsh-syntax-highlighting` — vermelho/verde antes de você apertar Enter
4. Edita seu `.zshrc` ativando os plugins (idempotente, faz backup em `.zshrc.destrave-backup`).
5. Torna `zsh` o shell padrão do seu usuário.

**Em Windows nativo** essa stack não existe. Por isso o kit usa **WSL2 + Ubuntu**
no Windows: o `install.ps1` instala WSL, e dentro do Ubuntu você roda esse
mesmo script. Resultado igual ao Mac.

## Atalhos que valem ouro

| Tecla | O que faz |
|-------|-----------|
| ↑ | Histórico (digite um pedaço antes pra filtrar) |
| → | Aceita a sugestão cinza (autosuggestions) |
| Tab | Autocomplete de arquivos, comandos, branches git |
| Ctrl+R | Busca reversa no histórico |
| Ctrl+A / Ctrl+E | Início / fim da linha |
| Ctrl+U / Ctrl+K | Apaga até o início / fim |
| Ctrl+W | Apaga uma palavra pra trás |
| `cd -` | Volta pro diretório anterior |
| `!!` | Reexecuta último comando (`sudo !!` é clássico) |

## Tema

Default fica `robbyrussell` — minimalista e estável. Outras boas opções:
`agnoster`, `gnzh`, `bira`. Edite `ZSH_THEME=` no seu `~/.zshrc` pra trocar.

Temas como `agnoster` precisam de **Nerd Font** pra renderizar os glifos.
[Cascadia Code NF](https://github.com/microsoft/cascadia-code) é uma boa.

## Troubleshooting

**"Permission denied" no chsh** — rode `chsh -s "$(which zsh)"` manualmente.
No WSL, talvez precise `sudo chsh -s $(which zsh) $USER` e reabrir o Ubuntu.

**Plugins não funcionam** — o script edita `.zshrc`, mas se você abrir um
terminal ainda em bash, o efeito não aparece. Feche e abra um terminal novo
ou rode `exec zsh`.

**Backup do .zshrc original** — está em `~/.zshrc.destrave-backup`. Pra
restaurar: `mv ~/.zshrc.destrave-backup ~/.zshrc`.
