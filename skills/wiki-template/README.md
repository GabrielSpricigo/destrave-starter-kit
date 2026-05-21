# Skill · Wiki template

Esqueleto mínimo de wiki persistente (Karpathy-style) para o LLM manter como
segundo cérebro: clientes, padrões, decisões, projetos, fontes.

## Fonte

Skill derivada de **[LLM-Wiki-Skilled](https://github.com/TrueHOOHA/LLM-Wiki-Skilled)**
(autor: TrueHOOHA). O template aqui é uma versão enxuta/cross-platform adaptada
ao fluxo Destrave — `_schema.md` simplificado, sem dependências PRODIA-specific,
com a regra B3α anti-vazamento mantida.

## O que o installer faz

`install-mac-linux.sh` copia `template/` pra um destino escolhido pelo mentorado
(default: `$PWD/wiki/`). Idempotente — não sobrescreve o que já existir, a menos
que você confirme.

## Estrutura criada

```
wiki/
├── _schema.md     regras pro LLM manter a wiki
├── index.md       mapa principal
├── log.md         log append-only de operações
├── clientes/      uma página por cliente
├── padroes/       processos repetíveis
├── decisoes/      ADRs
├── projetos/      seus projetos próprios
└── _fontes/       raw sources (transcrições, dossiês)
```

## Próximos passos depois de instalar

1. Aponte o Obsidian pra essa pasta pra navegar o grafo.
2. Leia `_schema.md` — é o contrato com o LLM.
3. Use `/wiki-ingest <arquivo>` (se você tiver a skill) ou peça pro Claude
   ingerir manualmente respeitando o schema.
