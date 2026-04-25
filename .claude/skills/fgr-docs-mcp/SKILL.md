---
name: fgr-docs-mcp
description: Use when working in FGR-Ops-docs with the fgr-docs-mcp MCP server — reading PRD/SPEC/flows, searching REQ-IDs or decisions, drafting DEC-NNN, or after editing docs/**/*.md files and needing search/list tools to reflect the change.
---

# fgr-docs-mcp — Guia de Uso

## Regra #0 — MCP primeiro, nunca leia docs/ diretamente

**NUNCA use `Read` ou `Glob` em arquivos sob `docs/`. Use sempre as ferramentas MCP.**

| Em vez de… | Use… |
|---|---|
| `Read "docs/PRD/01-usuarios-rbac.md"` | `get_prd("01")` |
| `Read "docs/SPEC/03-fila-scoring.md"` | `get_spec("03")` |
| `Read "docs/flows/04-despacho.md"` | `get_flow("04")` |
| `Read "docs/traceability.md"` | `get_traceability()` |
| `Grep "REQ-FUNC" docs/PRD/` | `list_req_ids(prefix: "FUNC")` |
| `Grep "scoring" docs/SPEC/` | `search_docs(query: "scoring", scope: "SPEC")` |
| `Read "docs/audit/decisions-log.md"` | `get_decision()` ou `get_decision(id: "DEC-NNN")` |

**Por quê:** O MCP retorna conteúdo já processado e mínimo. `Read` carrega o arquivo inteiro, `Glob`/`Grep` iterando `docs/` multiplica chamadas. Economia real: 5–20× menos tokens por consulta.

---

## Regra #1 — Reindexação após editar docs

**Editou qualquer `docs/**/*.md`? O hook PostToolUse reindexará automaticamente.**

Se precisar forçar manualmente:
```bash
npm --prefix C:/dev/fgr-docs-mcp run index
```

Saída esperada: `[indexer] Done — N files, N sections, N reqs, N decisions`

> **Segurança:** WAL mode — indexer funciona com o servidor MCP em execução. Sem necessidade de reiniciar.

---

## Taxonomia de ferramentas

| Ferramenta | Fonte | Precisa reindex? |
|---|---|---|
| `get_prd` | Filesystem | Não — sempre atual |
| `get_spec` | Filesystem | Não — sempre atual |
| `get_flow` | Filesystem | Não — sempre atual |
| `get_traceability` | Filesystem | Não — sempre atual |
| `get_infra` | Filesystem | Não — sempre atual |
| `get_ui_spec` | Filesystem | Não — sempre atual |
| `get_test_plan` | Filesystem | Não — sempre atual |
| `search_docs` | SQLite FTS5 | **Sim** |
| `list_req_ids` | SQLite | **Sim** |
| `get_decision` | SQLite | **Sim** |
| `get_acceptance_criteria` | SQLite + Filesystem | **Sim** (parte) |
| `draft_decision` | Escreve arquivo | Sim (após aplicar) |

---

## Referência de slugs

| Ferramenta | Slugs válidos | Exemplo |
|---|---|---|
| `get_prd` | `00`–`06`, `_index` | `get_prd("01")` |
| `get_spec` | `00`–`08`, `_index` | `get_spec("03")` |
| `get_flow` | `00`–`06`, `_index` | `get_flow("04")` |
| `get_ui_spec` | `design-system`, `spec-07`, `FGR-Ops/`, `Machinery-Link/` | `get_ui_spec("FGR-Ops")` |

O resolver faz prefix-match: o slug `01` resolve para o arquivo `01-*.md` no diretório.

---

## Workflow: rascunhar e aplicar decisão (DEC-NNN)

```
1. draft_decision(title, context, decision, rationale, affected_specs?)
   → gera MEMORY/decision-drafts/DEC-NNN-draft.md
   → se omitir `id`, o servidor sugere o próximo via nextDecId() (lê banco)

2. Revisar MEMORY/decision-drafts/DEC-NNN-draft.md
   Confirmar ID com CLAUDE.md ("Próxima: DEC-NNN")

3. Aplicar em docs/audit/decisions-log.md no formato canônico:
   ### DEC-NNN — Título
   - **Estado:** Ativo
   - **Data:** YYYY-MM-DD
   - **Contexto:** ...
   - **Decisão:** ...
   - **Justificativa:** ...
   - **SPECs/REQ-IDs afetados:** ...

4. Atualizar docs/traceability.md se houver impacto em cobertura

5. Hook reindexará automaticamente — get_decision() refletirá o novo DEC

6. Atualizar CLAUDE.md: "Próxima: DEC-NNN+1"
```

**Atenção:** `MEMORY/decision-drafts/` está fora de `DOCS_ROOT`. Rascunhos nunca aparecem em `search_docs`/`get_decision` — apenas após aplicação + reindex.

---

## Busca eficiente

```
# REQ-IDs por prefix
list_req_ids(prefix: "FUNC")
get_acceptance_criteria(reqId: "REQ-FUNC-005")

# Full-text com escopo
search_docs(query: "scoring", scope: "SPEC")
search_docs(query: "rollover redistribuicao", scope: "flows")

# Decisões
get_decision()                                   → índice completo
get_decision(id: "DEC-025")                      → conteúdo de uma
get_decision(from: "DEC-025", to: "DEC-030")     → range
```

---

## Erros comuns

| Situação | Problema | Correção |
|---|---|---|
| `list_req_ids` não retorna REQ-ID recém-criado | DB desatualizado | Forçar reindex manual |
| `get_decision("DEC-031")` NOT FOUND | Aplicado mas não reindexado | Forçar reindex manual |
| `draft_decision` sem `id` sugere DEC errado | DB desatualizado | Verificar `nextDecId` vs CLAUDE.md |
| `get_ui_spec("FGR-Ops")` vazio | Subdiretório incorreto | Chamar sem argumento para listar disponíveis |
| Rascunho em MEMORY/decision-drafts/ já existe | `draft_decision` rejeita duplicata | Revisar/renomear rascunho existente |
