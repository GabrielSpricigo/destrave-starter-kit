# Instalar conversando com o Claude

Você não precisa entender de terminal para usar este kit. Dá pra pedir para o
próprio Claude instalar e te explicar cada passo.

---

## Jeito mais simples: mande o link

Abra o Claude, cole o endereço do repositório e peça ajuda. Algo assim:

```
https://github.com/GabrielSpricigo/destrave-starter-kit

Me ajuda a instalar isso na minha máquina? Não sou técnico, então vai me
explicando o que está acontecendo.
```

Pronto. As instruções de instalação estão dentro do repositório, escritas para
ele — o Claude lê e conduz o processo com você, um passo por vez.

**Vale saber:** se você estiver usando o Claude pelo **navegador**, ele não
consegue mexer no seu computador. Ele vai te passar os comandos para você
colar, e você cola de volta o que apareceu na tela. Se estiver usando o
**Claude Code** (no terminal ou no aplicativo), ele instala sozinho.

---

## Se quiser um pedido mais detalhado

Serve para quando você quer deixar tudo explícito de uma vez — ou se o Claude
não seguiu o roteiro do repositório. Copie o bloco inteiro e cole na conversa:

```
Quero instalar o Destrave Starter Kit nesta máquina:
https://github.com/GabrielSpricigo/destrave-starter-kit

Antes de começar, leia o arquivo CLAUDE.md do repositório — ele tem o roteiro
de instalação e a lista de falhas conhecidas. Siga aquilo, não improvise.

Eu não sou técnico. Fale em português simples, um passo por vez, e me diga o
que vai acontecer antes de acontecer. Se aparecer erro, me explique o que
quebrou em vez de colar o log na tela.

Três coisas que eu quero que você garanta:

1. Descubra meu sistema operacional antes de mandar qualquer comando.
2. No fim, confirme que funcionou de verdade — não confie na mensagem de
   sucesso do instalador. Verifique se o comando `rtk gain` responde, se o
   arquivo de configuração do Claude Code tem o hook do RTK, e se o perfil do
   terminal existe mesmo em disco.
3. Se algo falhar, consulte as falhas conhecidas no CLAUDE.md antes de tentar
   uma solução alternativa da internet.

No final, me diga em três linhas o que mudou na minha máquina e qual é a
primeira coisa que eu deveria testar.
```

---

## Depois que terminar

Abra um terminal **novo** (no Windows, use o comando `pwsh`) e digite algum
comando que você já tenha usado antes. Deve aparecer uma **sugestão em cinza**
completando o resto — aceite com a seta `→`.

Essa sugestão é a prova visível de que deu certo.

Se ela não aparecer, volte na conversa e diga: *"a sugestão em cinza não
aparece no meu terminal"*. O Claude tem o contexto da instalação e a lista de
causas conhecidas — ele resolve.

---

## Prefere fazer você mesmo?

O caminho de um comando só está no [README](README.md#quickstart).
