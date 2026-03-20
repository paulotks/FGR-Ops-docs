# Documentação FGR-Ops (modular)

Este diretório contém o **PRD** (requisitos de produto) e a **SPEC** (especificação técnica) em módulos Markdown, com índices mestres e convenções de rastreio.

## Navegação

| Pacote | Índice | Descrição |
|--------|--------|-----------|
| PRD | [PRD/_index.md](PRD/_index.md) | Visão, utilizadores, jornada, RF, RNF, critérios de aceite, métricas e riscos |
| SPEC | [SPEC/_index.md](SPEC/_index.md) | Arquitetura, módulos, dados, fila/estados/SLA, RBAC, backlog MVP, complementos |

Os monolitos na raiz (`PRD-FGR-OPS.md`, `FGR-OPS-SPEC.md`) foram substituidos por stubs que apontam para `docs/`, evitando duas fontes de verdade. **Fonte atual:** navegar por `PRD/_index.md`, `SPEC/_index.md` e pela matriz global em [traceability.md](traceability.md).

## Convenções de identificadores

### PRD — `REQ-xxx`

- Prefixo global para requisitos de produto: **`REQ-`**.
- Sub-prefixos opcionais (legibilidade): `REQ-FUNC-`, `REQ-NFR-`, `REQ-ACE-`, `REQ-RBAC-`, ou numeração contínua `REQ-001`… com glossário no `_index.md` do PRD.
- Cada item que deva ser rastreado na SPEC deve ter **um ID** na primeira linha ou logo após o título, por exemplo: `**REQ-014** Descrição…`
- Critérios de aceite: mapear para `REQ-ACE-001` … (alinhado à secção 8 do PRD original, quando aplicável).

### SPEC — rastreio e IDs técnicos

- Em secções relevantes, indicar **`Rastreio PRD:`** com a lista de `REQ-xxx` cobertos.
- IDs técnicos próprios (`TECH-*`) apenas para detalhe não coberto pelo PRD; listar no `_index.md` da SPEC quando existirem.

### Ligações cruzadas

- Do PRD para a SPEC: linha curta `→ SPEC: [caminho-relativo](...#âncora)`.
- Da SPEC para o PRD: bloco **`Rastreio PRD:`** com IDs.
- Âncoras Markdown nas secções SPEC: `## Título {#identificador-ancora}`.

### Matriz global

- Matriz global de rastreio: [traceability.md](traceability.md) (`REQ` ↔ ficheiros PRD/SPEC).

---

*Estado da migração: documentação modular em `docs/` é a referência oficial; ficheiros da raiz permanecem apenas como ponteiros de navegação.*
