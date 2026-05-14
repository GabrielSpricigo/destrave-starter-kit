# Skill · MemPalace (opt-in, avançado)

MCP server que dá ao Claude memória semântica entre conversas: Knowledge
Graph (triples sobre entidades — clientes, projetos, pessoas) + busca
vetorial. O Claude recupera percepções de sessões anteriores mesmo que você
nem lembre de ter falado.

> **Por que opt-in:** exige Python 3.10+, ChromaDB (~300MB de deps) e edição
> do `.mcp.json` do seu projeto. Quem está começando deve pular — a Wiki
> resolve 80% do problema com 5% da complexidade. Volte aqui quando sentir
> falta de "lembrar do que conversamos mês passado".

## Pré-requisitos

- Python 3.10+ disponível como `python3`
- `pip` funcionando
- Claude Code com suporte a MCP servers (`.mcp.json` no projeto OU global)
- ~500MB livres (ChromaDB + sentence-transformers baixam modelo na 1ª run)

## Instalação

### Mac, Linux, WSL

```bash
bash install-mac-linux.sh
```

O script:
1. Confere Python 3.10+
2. Instala o pacote `mempalace` via pip (no `--user` site-packages)
3. Imprime o trecho de JSON pra você colar no seu `.mcp.json`

### Configurar no Claude Code

Cole o JSON impresso pelo installer em `.mcp.json` na raiz do seu projeto:

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "/caminho/absoluto/para/python3",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_DIR": "/caminho/do/seu/projeto"
      }
    }
  }
}
```

**Importante:** `command` precisa ser **caminho absoluto** (não `python3` bare).
Upgrade de Homebrew/apt pode quebrar o path se você usar nome bare.

Depois, reinicie o Claude Code — `mempalace_status` aparece nas tools.

## Como usar (resumo)

- `mempalace_kg_add subject="<entidade>" predicate="<tipo>" object="<conteúdo>" valid_from="YYYY-MM-DD"` — registra triple
- `mempalace_kg_query entity:"<nome>"` — recupera tudo sobre uma entidade
- `mempalace_search "<termo>"` — busca semântica em drawers (blobs livres)
- `mempalace_kg_invalidate <triple_id>` — marca triple como histórico expirado

## Armadilhas conhecidas

⚠️ **Nunca rode `mempalace mine .` na raiz de um repo grande.** Gera milhares
de chunks lixo e afoga a busca semântica. Se quiser indexar, alvo específico
(ex: só `wiki/`).

⚠️ **Default = KG triple, não drawer.** Drawer é blob de texto livre, sem
estrutura. Use só quando o conteúdo realmente não cabe em triple.

⚠️ **Nunca use room `general`.** Crie room específica (`clientes`, `projetos`,
`decisoes`). Room genérica vira lixeira semântica.
