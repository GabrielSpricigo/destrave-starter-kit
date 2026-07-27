# Instalar conversando com o Claude Code

Se você não se sente à vontade com o terminal, não precisa usar. Dá pra pedir
pro próprio Claude Code instalar o kit e te explicar cada passo.

**Como fazer:** abra o Claude Code, copie o texto do bloco abaixo (o botão de
copiar aparece no canto), cole na conversa e mande. Só isso.

---

```
Quero instalar o Destrave Starter Kit nesta máquina. Você vai conduzir a
instalação e me explicar o que está acontecendo — eu não sou técnico, então
fale em português simples e evite jargão. Quando precisar usar um termo
técnico, explique em uma linha antes de usar.

Passo a passo que quero que você siga:

1. Descubra meu sistema operacional antes de qualquer coisa.

2. Baixe o kit para a minha pasta de usuário:
   https://github.com/GabrielSpricigo/destrave-starter-kit
   Se eu já tiver o kit baixado, atualize em vez de baixar de novo.

3. Rode o instalador do meu sistema:
   - Windows: install.ps1
   - Mac ou Linux: install.sh
   Quando o menu aparecer, escolha a opção "Tudo" — a não ser que eu peça
   outra coisa.

4. Enquanto instala, me diga em uma frase o que cada peça faz e por que ela
   existe. Não despeje log na tela sem explicar.

5. No final, confirme que funcionou de verdade — não confie na mensagem de
   sucesso do instalador, verifique você mesmo:
   - o comando `rtk gain` responde?
   - o arquivo de configuração do Claude Code tem o hook do RTK?
   - o perfil do terminal foi realmente gravado no disco?

Se algo der errado, olhe esta lista antes de tentar outra coisa — são as
quatro falhas conhecidas neste kit, e nenhuma delas dá mensagem de erro
óbvia:

a) O Windows recusa rodar scripts (política de execução). Rode o instalador
   com -ExecutionPolicy Bypass.

b) A gravação em Documentos "funciona" mas o arquivo não existe depois. É o
   Acesso Controlado a Pastas do Windows Defender. Sempre confirme que o
   arquivo existe depois de gravar; se não existir, me avise e use um
   caminho alternativo em vez de seguir como se tivesse dado certo.

c) O PowerShell 7 foi instalado mas o comando `pwsh` não é encontrado. Ele
   fica em AppData\Local\Microsoft\WindowsApps, não em Arquivos de
   Programas. Às vezes só aparece depois de abrir um terminal novo.

d) Um programa foi instalado mas o comando ainda não funciona. Quase sempre
   é o terminal atual com a lista de programas desatualizada — abra um novo.

No final, me diga em 3 linhas o que mudou na minha máquina e qual é a
primeira coisa que eu deveria testar.
```

---

## Depois que terminar

Abra um terminal novo (no Windows, use o comando `pwsh`) e digite qualquer
comando que você já usou antes. Deve aparecer uma **sugestão em cinza**
completando o resto — aceite com a seta `→`.

Se a sugestão não aparecer, volte no Claude Code e diga: *"a sugestão em
cinza não aparece no meu terminal"*. Ele tem o contexto da instalação e
consegue diagnosticar.

## Prefere o terminal?

O caminho de um comando só está no [README](README.md#windows).
