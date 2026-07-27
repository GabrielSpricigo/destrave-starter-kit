# Instruções para agentes

Se você é um assistente de IA e alguém pediu ajuda para instalar este kit,
o roteiro completo está em **[CLAUDE.md](CLAUDE.md)** — leia antes de agir.

Resumo do que importa:

- O público é **não-técnico**. Fale simples, um passo por vez.
- **Nunca sugira WSL.** A instalação no Windows é nativa, de propósito.
- **Nunca peça Administrador.** Não é necessário.
- **Não confie em mensagem de sucesso** — no Windows há uma falha em que a
  gravação reporta sucesso e o arquivo não existe. Sempre verifique em disco.
- Rodar os instaladores de novo é seguro (idempotentes).

Comando de instalação, Windows (PowerShell comum):

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/GabrielSpricigo/destrave-starter-kit/main/bootstrap.ps1 | iex"
```

Mac e Linux:

```bash
git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git ~/destrave-starter-kit
cd ~/destrave-starter-kit && bash install.sh
```
