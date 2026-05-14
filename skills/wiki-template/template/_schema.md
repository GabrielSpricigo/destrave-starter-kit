---
name: Wiki Schema
description: Regras pro LLM manter sua wiki. Leia antes de qualquer ingest ou edição.
type: reference
---

# Wiki Schema

> Contrato entre você (LLM) e esta wiki. Antes de criar ou atualizar página, leia
> as regras abaixo. Seguir o schema é o que transforma a wiki em conhecimento
> composto — não em mais uma pasta de docs avulsos.

---

## O que é esta wiki

Uma wiki **persistente e composta** (Karpathy-style). É o que um novo
colaborador (ou você mesmo daqui a 6 meses) leria pra entender tudo que
você sabe sobre seus clientes, processos e decisões.

**Camadas em volta dela:**

- **MemPalace / memory store** → fila de ideias soltas e percepções pendentes (opcional)
- **Tasks / ClickUp / Linear** → checkpoint de andamento, não onde planejamento mora
- **Pastas operacionais** (`docs/`, `infra/`, `scripts/`) → tecnicidade, não conhecimento

**A wiki guarda:** o que aprendemos sobre clientes, como fazemos as coisas,
por que tomamos decisões.

---

## Tipos de página

### 1. `clientes/<slug>.md`

Conhecimento acumulado sobre um cliente.

**Frontmatter:**
```yaml
---
type: cliente
tags: [cliente, <slug-do-cliente>]
updated: YYYY-MM-DD
related: []
---
```

**Seções obrigatórias:**
- `## Overview` — O que o cliente faz, segmento, porte, contexto
- `## Contatos` — Pessoas, cargos, canais de comunicação
- `## Canais e Plataformas` — Onde estão presentes
- `## Tom e Linguagem` — Como falam, o que evitar
- `## Projetos Ativos` — O que está sendo feito agora
- `## Aprendizados` — O que funcionou / não funcionou / padrões
- `## Histórico de Contexto` — Decisões e mudanças de direção (datadas)

**Guardrail B3α — anti-vazamento:** páginas de cliente **NÃO devem conter**
informações internas do seu negócio (margem, fee, custo interno, processo
interno, repasse, comissão sua). Isso vai em `projetos/<seu-negocio>.md`.

### 2. `padroes/<processo>.md`

"Como fazemos X aqui." Evolui com a prática.

**Frontmatter:**
```yaml
---
type: padrao
tags: [padrao, <area>]
updated: YYYY-MM-DD
related: []
---
```

**Seções obrigatórias:**
- `## O que é` — Descrição em 2-3 frases
- `## Quando usar` — Gatilho/contexto
- `## Como fazer` — Passo a passo
- `## Ferramentas` — Skills, scripts, serviços envolvidos
- `## Armadilhas` — O que costuma dar errado
- `## Exemplos` — Casos reais

### 3. `decisoes/<tema>.md` — ADR

Por que escolhemos X em vez de Y. **Não editar após criado** — só deprecar
e criar nova decisão se mudar.

**Frontmatter:**
```yaml
---
type: decisao
tags: [decisao, <area>]
status: ativa | deprecada
date: YYYY-MM-DD
related: []
---
```

**Seções obrigatórias:**
- `## Contexto` — Qual problema estava sendo resolvido
- `## Decisão` — O que foi decidido (1 frase clara)
- `## Razão` — Por que essa opção e não outra
- `## Consequências` — Implicações positivas e negativas
- `## Alternativas consideradas` — O que foi descartado e por quê

### 4. `projetos/<slug>.md`

Contexto de projetos seus (não de clientes).

**Frontmatter:**
```yaml
---
type: projeto
tags: [projeto, <slug>]
status: ativo | pausado | encerrado
updated: YYYY-MM-DD
related: []
---
```

**Seções obrigatórias:**
- `## O que é` — Descrição
- `## Objetivo` — O que resolve/entrega
- `## Stack / Infraestrutura` — Tecnologias, onde roda
- `## Estado atual` — O que funciona, o que está pendente
- `## Decisões chave` — Links pra `[[decisoes/]]`
- `## Próximos passos`

---

## Convenções

### Links internos (Obsidian-compatible)

Use `[[nome-do-arquivo]]`, não `[texto](path/arquivo.md)`. Exemplos:
- `[[clientes/acme]]`
- `[[padroes/captura-leads]]`
- `[[decisoes/escolha-crm]]`

### Datas

ISO 8601 sempre: `YYYY-MM-DD`. Atualizar `updated` no frontmatter a cada edição.

### Tags

- kebab-case: `trafego-pago`, não `Tráfego Pago`
- Tipo: `cliente`, `padrao`, `decisao`, `projeto`
- Área: livre (`crm`, `ads`, `criativos`, etc.)

---

## Regras de ingest

Ao receber uma fonte (transcrição, doc, conversa):

1. **Identificar entidades** — quais clientes, projetos, padrões são mencionados
2. **Página existe?**
   - Sim → merge inteligente (adicionar à seção correta, sem sobrescrever)
   - Não → criar usando o template do tipo correto
3. **Extrair conhecimento** — o que é novo, o que confirma, o que contradiz
4. **Marcar contradições** — `> ⚠️ Conflito: [descrição]` com data
5. **Atualizar `updated`** no frontmatter
6. **Registrar em `_fontes/`** — guardar a fonte original (transcrição, PDF, etc.)
   e citar no `related` da página atualizada

---

## O que NÃO guardar na wiki

| Não guardar | Onde fica |
|---|---|
| Senhas, tokens, IPs, secrets | `.env` ou gerenciador de senhas |
| Artefatos one-shot (propostas, PRDs) | `_bmad-output/` ou pasta de projeto |
| Transcrições brutas | `_fontes/` (raw sources, append-only) |
| Code snippets | repositório de código, não wiki |
| Memória semântica de conversas | MemPalace (se usar) |

A wiki guarda **síntese e contexto**, não dados brutos.

---

## Camada raw — `_fontes/`

Material primário imutável: transcrições, dossiês, capturas. **Append-only**:
novas fontes entram, fontes existentes não são editadas após citadas em uma
página da wiki. Se precisa corrigir, criar `-v2.md`.

Ao processar fonte, citar no `related` da página de destino e registrar em
`log.md`.

---

## Log cronológico (`log.md`)

Toda operação relevante (`ingest`, `decisao`, `migracao`) appenda **uma
entrada** em `log.md`:

```
## [YYYY-MM-DD] <op> | <Título curto>
- bullet 1 (≤1 linha)
- bullet 2
```

Append-only e parseável (`grep "^## \[" wiki/log.md | tail -10`).
