# Instruções para o assistente de IA que vai instalar este kit

Se você é um assistente (Claude, ou outro) e alguém te mandou o link deste
repositório pedindo ajuda para instalar: **este arquivo é o seu roteiro.**
Siga daqui, não improvise a partir de conhecimento geral sobre terminais.

---

## Quem está do outro lado

Um mentorado do **Destrave Claude Code**. Empresário ou profissional, **não é
programador**. Provavelmente nunca usou terminal antes e tem receio de quebrar
o computador.

Como falar com essa pessoa:

- Português simples. Nada de jargão sem explicar.
- Um passo por vez. Espere a resposta antes de mandar o próximo.
- Diga o que vai acontecer **antes** de acontecer ("vai aparecer um monte de
  texto rolando na tela, é normal").
- Se aparecer erro, não despeje o log. Traduza: o que quebrou, por quê, o que
  fazer.
- Nunca diga "é só rodar". Para essa pessoa, nada é "só".

---

## Passo 0 — Descubra o que você consegue fazer

**Se você consegue executar comandos na máquina** (Claude Code no terminal ou
no app de desktop): conduza a instalação você mesmo, narrando cada passo.

**Se você só conversa** (claude.ai no navegador, sem acesso ao computador):
você não pode instalar nada. Entregue os comandos prontos para a pessoa colar,
peça para ela colar de volta o que apareceu, e interprete o resultado. Deixe
isso claro logo no começo, para ela não ficar esperando algo acontecer sozinho.

## Passo 1 — Descubra o sistema operacional

Não presuma. Se você tem acesso à máquina, verifique. Se não tem, pergunte:
*"Você está no Windows, no Mac, ou no Linux?"*

O caminho é diferente em cada um, e errar aqui faz a pessoa perder tempo.

## Passo 2 — Rode o instalador

**Windows** — no PowerShell comum (**não** precisa ser Administrador):

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/GabrielSpricigo/destrave-starter-kit/main/bootstrap.ps1 | iex"
```

**Mac**:

```bash
git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git ~/destrave-starter-kit
cd ~/destrave-starter-kit && bash install.sh
```

**Linux**: igual ao Mac.

Quando o menu aparecer, a escolha é **`a`** (Tudo), a menos que a pessoa peça
outra coisa. O MemPalace fica fora do "Tudo" de propósito — é avançado e só
deve entrar se ela pedir.

## Passo 3 — Verifique de verdade

**Não conclua que deu certo porque o instalador disse que deu.** Este kit tem
uma falha conhecida em que a gravação reporta sucesso e o arquivo não existe
(veja abaixo). Confira você mesmo:

1. O comando `rtk gain` responde?
2. O arquivo `~/.claude/settings.json` contém `rtk hook claude`?
3. O perfil do terminal existe mesmo em disco?
4. Num terminal **novo**: aparece sugestão em cinza ao digitar um comando já usado?

No Windows, o terminal novo precisa ser o **PowerShell 7** (comando `pwsh`),
não o que abre por padrão.

---

## Falhas conhecidas — consulte antes de tentar qualquer outra coisa

Nenhuma delas dá mensagem de erro clara. Se a instalação estranhar, é
provavelmente uma destas quatro.

**1. O Windows recusa rodar o script**
Sintoma: "não é possível carregar o arquivo... não está assinado digitalmente",
ou dois cliques no `.ps1` e nada acontece.
Causa: política de execução do Windows, que vem restrita.
Correção: rodar com `-ExecutionPolicy Bypass`, como no comando acima.

**2. Gravou "com sucesso" mas o arquivo não existe**
Sintoma: o instalador diz que instalou o perfil, mas nada mudou no terminal.
Causa: **Acesso Controlado a Pastas** do Windows Defender, que bloqueia
gravação na pasta Documentos sem gerar erro nenhum.
Correção: o instalador detecta isso sozinho e usa um caminho alternativo,
avisando na tela. Se você estiver gravando algum arquivo por conta própria,
**sempre confirme que ele existe depois** — nunca assuma. Para liberar de vez,
no PowerShell como Administrador:
`Set-MpPreference -EnableControlledFolderAccess Disabled`

**3. Instalou, mas o comando não é encontrado**
Sintoma: `pwsh`, `rtk` ou `node` "não é reconhecido" logo após instalar.
Causa: o terminal aberto ainda tem a lista de programas antiga. No caso do
PowerShell 7, ele também não fica em Arquivos de Programas — o winget instala
como app da Store, em `AppData\Local\Microsoft\WindowsApps`.
Correção: fechar o terminal e abrir um novo. Se for procurar o executável, use
`Get-Command`, nunca um caminho fixo.

**4. O texto aparece embaralhado ("instalaÃ§Ã£o")**
Causa: arquivo `.ps1` salvo sem BOM. Todo `.ps1` deste repositório **precisa**
ser UTF-8 **com BOM** — sem ele, o Windows PowerShell 5.1 lê como ANSI.
Correção: se você editar algum `.ps1` daqui, preserve o BOM.

---

## Regras para você, assistente

- **Nunca sugira WSL.** Até julho de 2026 este kit instalava WSL2 + Ubuntu no
  Windows, e isso foi removido de propósito. O motivo: mesmo rodando `claude`
  dentro do Ubuntu, quem executava era o Claude do **Windows**, gravando tudo
  no perfil do Windows — o RTK também. O WSL só somava uma camada de tradução,
  que causava problemas como colar texto errado. Se a pessoa já tem WSL, tudo
  bem, mas a instalação é nativa.
- **Nunca peça Administrador.** A instalação no Windows inteira roda com
  usuário comum. Se você achou que precisa de admin, provavelmente está indo
  pelo caminho errado. A única exceção é desligar a proteção do Defender, que
  é opcional.
- **Não invente comandos de outras fontes.** Use os instaladores deste repo.
  Se algo não funcionar, diagnostique com a lista acima em vez de partir para
  uma solução alternativa da internet.
- **Não instale nada além do que o kit instala.** A pessoa confiou o
  computador dela a você.
- **Rodar de novo é seguro.** Todos os instaladores são idempotentes: não
  duplicam configuração nem sobrescrevem calibrações que ela já tenha feito.

## No fim

Diga em três linhas o que mudou na máquina dela, e qual é a primeira coisa
para testar. Sugira abrir um terminal novo e digitar um comando qualquer que
ela já tenha usado, para ver a sugestão em cinza aparecer — é a prova visível
de que funcionou.

---

Detalhes de cada peça: [README.md](README.md).
Prompt pronto para a pessoa colar: [INSTALAR-PELO-CLAUDE.md](INSTALAR-PELO-CLAUDE.md).
