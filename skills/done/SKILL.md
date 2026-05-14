---
name: done
description: Ritual de fim de sessão — calibração de skills (Nível 4) + comemoração + ClickUp opcional. Use ao terminar uma etapa, task ou projeto.
---

Execute EXATAMENTE os passos abaixo, em ordem.

## 0. Inferir o escopo

Antes de tudo, identifique o **escopo** do `/done` desta sessão:

- **Fim de etapa** — entregamos um passo dentro de uma task maior; ainda há trabalho na frente
- **Fim de task** — a task completa foi entregue
- **Fim de projeto** — o projeto inteiro fechou

A inferência sai do contexto da conversa. Em dúvida, pergunte:
> *"Esse `/done` é fim de etapa, fim de task ou fim de projeto?"*

O escopo calibra a comemoração (passo 3) e o registro em ClickUp (passo opcional).

---

## 1. Espelhar conclusão no ClickUp (opt-in)

> **Esta seção só roda se o mentorado configurou ClickUp.** Procure por
> `$HOME/.claude/state/clickup-config.json`. Se não existir, **pule pro passo 2**.

Se houve uma task ativa nesta sessão (id em `$HOME/.claude/state/active-task.json`):

1. Lê o token do ClickUp de `$HOME/.claude/state/clickup-config.json` (campo `token`).
2. Lê o `task_id` de `$HOME/.claude/state/active-task.json`.
3. Posta um comentário plain-text na task com:
   - 1 linha do que foi entregue
   - Bullets dos artefatos (paths/links)
   - "Próximo passo:" se for fim de etapa, ou "—" se fim de task/projeto
4. Atualiza o status:
   - Fim de etapa → status configurado (default `in progress`)
   - Fim de task ou projeto → status configurado (default `shipped` ou `done`)
5. Apaga `active-task.json` se foi fim de task/projeto.

Curl exemplo (plain text — a API do ClickUp **não suporta markdown** em comentários):

```bash
curl -X POST "https://api.clickup.com/api/v2/task/$TASK_ID/comment" \
  -H "Authorization: $CLICKUP_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"comment_text": "✅ <resumo plain-text>"}'
```

Se erro de API, **pare o fluxo** e reporte ao usuário antes de seguir.

---

## 2. Memory checkpoint (opcional, se houver memory store)

Se você tem um **memory store configurado** (auto-memory, MemPalace, ou qualquer
sistema persistente entre sessões):

1. Identifique entidades nomeadas discutidas (cliente, projeto, ferramenta, decisão).
2. Para cada uma, decida o que persistir:
   - **Insights, hipóteses, side quests** → memory store (com data ISO)
   - **Decisão arquitetural ou de processo** desta sessão → `wiki/decisoes/` (propor primeiro)
   - **Padrão novo** → `wiki/padroes/` (propor primeiro)
   - **Fato novo sobre cliente** → `wiki/clientes/<slug>.md`
   - **Feedback do usuário que se repetiu** → seção `## Calibração aprendida` da skill alvo (passo 2.5)

Exiba um resumo curto (1-3 bullets) do que foi/será persistido. Se nada, diga
"Nada a consolidar."

Se você **não tem memory store configurado**, pule este passo.

---

## 2.5. Scan de calibração (auto-improvement Nível 4)

> Detecta feedback implícito da sessão e propõe calibração das skills usadas.
> **O usuário é o gate humano.** Nada é aplicado sem aprovação.

### 2.5.1 Inventário de skills usadas

Liste as skills que rodaram nesta conversa (slash commands ou skills via Skill
tool). Ignore:
- Skills que apareceram em listagens mas não rodaram
- Frameworks upstream que você não controla

Lista vazia → exiba `✨ Nenhuma skill foi usada nesta sessão. Pulando scan.`
e siga pro passo 3.

### 2.5.2 Heurística de detecção

Pra cada skill no inventário, varra a sessão buscando:

- **Correção direta** — "não faz X aqui", "isso tá errado", "tinha que ter Y"
- **Regra projetada** — "da próxima vez X", "sempre faz Y", "isso é regra"
- **Retrabalho manual** — você editou o output da skill após ela rodar
- **Surpresa repetida** — mesma fricção apareceu mais de uma vez
- **Menção explícita** — "a skill X precisa..."

**Exclua:** feedback contextual à sessão ("dessa vez não precisa"), correções
de erro óbvio (typo, param errado), reações sem prescrição ("legal", "perfeito").

**Cap:** máximo 5 candidatos. Se passar, ranqueie por confiança.

### 2.5.3 Cruzamento com calibração existente

Antes de mostrar o menu, pra cada candidato:

1. Leia o bloco `## Calibração aprendida → ### Regras vivas` da skill alvo.
2. Detecte: duplicata, conflito ou regra nova.

### 2.5.4 Menu interativo

```
🔍 Detectei N feedback(s) candidato(s) a virar calibração:

[1] "<resumo do feedback ≤200 chars>"
    ↳ skill(s) sugerida(s): /skill-a
    ↳ status: [novo | já existe | conflito]
    aplicar? (s / n / editar) >

[2] ...
```

**Opções:**
- `s` — aplica protocolo P2 (insere bullet datado no topo de `### Regras vivas`)
- `n` — descarta
- `editar` — você reescreve o bullet antes de aplicar

Aceite respostas em batch (ex: `1s 2n 3editar`).

### 2.5.5 Aplicação

Pra cada candidato aprovado:

1. Edite o SKILL.md da skill alvo inserindo `- [YYYY-MM-DD] <regra ≤200 chars>`
   no topo de `### Regras vivas`.
2. Se já há 10 bullets, mova o mais antigo (data ascendente) pro final do arquivo
   numa seção `<!-- overflow -->` antes do append.
3. Confirme: `✅ Calibração aplicada em /<skill>. (regra X/10)`

Resumo final:
```
📐 Calibração: X aplicada(s), Y descartada(s), Z editada(s).
```

---

## 3. Comemoração

Calibre ao escopo:

- **Fim de etapa** — comemoração leve (1 emoji, 1 linha)
- **Fim de task** — comemoração média (3-4 emojis, 2 linhas)
- **Fim de projeto** — comemoração explícita (emoji forte + resumo do que entregamos)

Exemplos:

- Etapa: `✅ Etapa concluída.`
- Task: `🚀 Task entregue! [resumo de 1 linha do que foi feito].`
- Projeto: `🎉 PROJETO FINALIZADO! Entregamos: [resumo de 2-3 bullets].`

Se você tem áudio/recurso visual configurado (ex: arquivos em
`$HOME/.claude/done-assets/`), pode tocar/abrir aqui — opcional.

---

## 4. Mensagem final ao usuário

Exiba **apenas isto** no chat:

> 🚀 **MISSÃO CUMPRIDA!** Digite `/clear` pra resetar a sessão.

(ou variante por escopo — etapa: "Etapa feita, segue o jogo."; projeto: "PROJETO ENTREGUE 🎉🎉🎉")

---

## Configurar ClickUp (opt-in, primeira vez)

Se você quer que `/done` espelhe conclusões no ClickUp, peça pro Claude criar:

**`$HOME/.claude/state/clickup-config.json`:**
```json
{
  "token": "pk_xxx_seu_token_clickup",
  "default_list_id": "id-da-sua-lista",
  "status_etapa": "in progress",
  "status_task": "shipped",
  "status_projeto": "done"
}
```

Token: gere em ClickUp > Settings > Apps > API Token.

A skill `/done` checa esse arquivo antes de tentar postar comentário. Sem ele,
o passo 1 vira no-op.

---

## Calibração aprendida
<!-- Auto-improvement Nível 4. Cap: 10 regras × 200 chars. -->

**Protocolo (P2):** ao detectar feedback aplicável, edite este arquivo inserindo
bullet `- [YYYY-MM-DD] <regra ≤200 chars>` no topo de `### Regras vivas`. Cap 10:
se passar, mova o bullet mais antigo (data asc) pra `<!-- overflow -->` no final.

### Regras vivas

<!-- bullets mais recentes no topo. formato: - [YYYY-MM-DD] <regra> -->
