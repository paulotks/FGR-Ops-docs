# CLAUDE.md — FGR Ops Requisitos

**Repositório documentation-only** do FGR-OPS (Machinery Link MVP). Nunca criar/editar código-fonte de produto (`.ts`, `.prisma`, `.tsx`, controllers, migrations, etc.) aqui.

---

## Stack & Estrutura

| Path / Camada | Conteúdo / Convenção |
|---|---|
| `docs/PRD/_index.md` | Índice PRD e registro de REQ-IDs |
| `docs/SPEC/_index.md` | Índice SPEC e overview arquitetural |
| `docs/traceability.md` | **Matriz global** — atualizar sempre que PRD/SPEC mudar |
| `docs/flows/` | Diagramas Mermaid (fluxos, ER, sequência) |
| `docs/audit/decisions-log.md` | Decisões táticas `DEC-001…` (append-only) |
| `docs/changes/` | Pacotes OpsX ativos (propose → apply → archive) |
| `MEMORY/` | Wake-up, journal, decisions, inbox |
| Formato base | Markdown + front-matter YAML; ADRs D1–D7 em `SPEC/00` |

**Target stack (referência de redação):** Vite + React 19 PWA · Tailwind + shadcn/ui · TanStack Router/Query · react-hook-form + zod · Zustand · NestJS 10+ · Turborepo/pnpm · SQL Server + Prisma · JWT/Redis RBAC · Deploy Windows Server + IIS + PM2 · Mobile futuro: Expo + React Native

| ADR | Decisão |
|---|---|
| D1 | Turborepo monorepo — packages compartilhados (`types`, `schemas`, `api-client`, `domain`) entre web/mobile/backend |
| D2 | SQL Server + Prisma ORM |
| D3 | JWT + Redis blacklist + rate limiting |
| D4 | Multi-tenancy lógico: `obraId` em todas as tabelas de negócio |
| D5 | SuperAdmin/Board bypass tenant filter; acesso cross-tenant auditado |
| D6 | Campo (Empreiteiro/Operador): PIN 6 dígitos; Admin: senha forte, rotação 180 dias |
| D7 | Vite + React 19 + Tailwind + shadcn/ui (DEC-021, supersede DEC-007/DEC-008); deploy IIS estático + PM2/NestJS (DEC-022); mobile RN/Expo preparado (DEC-023) |

---

## Identifiers

- **PRD:** `REQ-<PREFIX>-<NNN>` — prefixes: `FUNC NFR ACE RBAC JOR CTX OBJ MET RISK`
- **SPEC:** bloco `**Rastreio PRD:**` obrigatório em toda seção que referencie REQ-IDs
- **Decisões táticas:** `DEC-NNN` em `decisions-log.md` — próxima: **DEC-024**
- **ADRs:** `D1–D7` nas SPECs
- **Cross-links:** PRD→SPEC `→ SPEC: path#anchor` · SPEC→PRD bloco `Rastreio PRD:`

---

## Regras (inegociáveis)

1. **Sem código-fonte de produto** neste repositório
2. **Prefixes padrão apenas** — novo prefix exige `DEC-NNN`
3. **`Rastreio PRD:` obrigatório** em toda seção SPEC com REQ-IDs
4. **Cross-links bidirecionais** — todo link resolve para anchor existente
5. **`traceability.md` atualizado** a cada mudança PRD/SPEC estável
6. **Mudanças não-triviais via OpsX** (propose → apply → archive)
7. **Diagramas em Mermaid** em `docs/flows/`
8. **`decisions-log.md` append-only** — superseder com nova `DEC-NNN`
9. **Sem `TBD`/`TODO`** em docs estáveis sem entry em `MEMORY/inbox.md`
10. **Sem segredos/CPFs/e-mails reais** em exemplos
11. **Sem REQ-ID inventado** sem registro em `_index.md` e arquivo PRD correspondente

---

## Feature Request Workflow

```
1. Ler PRD relevante  →  docs/PRD/_index.md + arquivo afetado
2. Ler SPEC relevante →  docs/SPEC/_index.md + módulo afetado
3. Verificar decisões →  docs/audit/decisions-log.md (conflito? → DEC-NNN)
4. Implementar        →  criar/editar PRD + SPEC + traceability.md
5. Validar            →  /audit + quality gates
```

---

## Routing Table

| Situação | Ação |
|---|---|
| Novo requisito funcional | `REQ-FUNC-NNN` em `docs/PRD/`, atualizar `_index.md`, seção SPEC com `Rastreio PRD:`, atualizar `traceability.md` |
| Nova decisão arquitetural | `DEC-NNN` em `decisions-log.md`, referenciar SPEC afetado |
| Novo fluxo operacional | Diagrama Mermaid em `docs/flows/`, linkar de PRD e SPEC |
| Mudança em requisito existente | Pacote OpsX em `docs/changes/`, workflow apply → archive |
| Novo conceito de domínio | SPEC domain model + glossário `SPEC/05` + ER se necessário |
| Ambiguidade PRD ↔ SPEC | `/audit` → propor resolução → `DEC-NNN` se arquitetural |
| Novo perfil/permissão | `PRD/01-usuarios-rbac.md` + `SPEC/04-rbac-permissoes.md` + `traceability.md` |
| Novo critério de aceite | `REQ-ACE-NNN` em `PRD/05-criterios-aceite.md`, mapear em `traceability.md` |
| Revisão SLA/estado Demanda | `SPEC/03-fila-scoring-estados-sla.md`, verificar PRD/02 e PRD/03, DEC se novo |

---

## Quality Gates

- [ ] `/audit` — zero CRITICAL não-justificados
- [ ] `traceability.md` sem REQ-IDs órfãos nem SPECs sem rastreio
- [ ] REQ-IDs novos em `docs/PRD/_index.md`
- [ ] Cross-links bidirecionais resolvem
- [ ] Mermaid sem erro de sintaxe
- [ ] Decisões em `DEC-NNN`; ADRs em `D1–D7`
- [ ] Glossário consistente com SPECs
- [ ] Pacote OpsX arquivado após aplicação

---

## Domain (FGR-OPS)

Plataforma multi-tenant de operações de construção civil. MVP = **Machinery Link** — requisição, despacho, execução e rastreamento de maquinário pesado.

- **Demanda** — aggregate root; estados: `PENDENTE → EM_ANDAMENTO → CONCLUIDA / CANCELADA / RETORNADA`; também `AGENDADA → PENDENTE_APROVACAO`
- **Queue engine** — filtro setor/equipamento + scoring: `score = (W_adj×adjacency) + (W_srv×service_priority) + (W_mat×material_risk)`; pesos 50/30/20; empates por FIFO
- **SLA:** MAXIMA 15 min · ELEVADA 45 min · NORMAL 120 min; timeout → `PENDENTE_APROVACAO` → auto-encerramento no fim do expediente
- **`exigeTransporte`** em `Servico` — torna origem→destino obrigatório na criação da Demanda

---

## Current State (2026-04-16)

| | Estado |
|---|---|
| PRD | 7 módulos estáveis (`00`–`06`); REQ-IDs: CTX-001…003, OBJ-001…005, SCO-001…005, SCO-F2-001…006, SCO-GAT-001…004, RBAC-001…006, JOR-001…005, FUNC-001…013, NFR-001…007, ACE-001…006+008, MET-001…003, RISK-001…002 |
| SPEC | 9 módulos + UI-DESIGN.md; cobertura 62 cobertos / 2 parciais / 0 descobertos |
| Decisions | Última: DEC-024 · Próxima: **DEC-025** |
| OpsX ativos | `stack-frontend-vite-react` (em aplicação — DEC-021/022/023) |
| Audit | 37 achados, todos resolvidos · `docs/audit/output/global/consolidated-global.json` |

---

## Skills · Persona

- `/audit` — verifica consistência PRD ↔ SPEC ↔ `traceability.md`
- `/spec` — guia de redação de seções SPEC com rastreio correto

**Persona:** arquiteto de documentação sênior. Preciso, bidirecional, rastreabilidade antes de tudo. Em dúvida sobre escopo → perguntar antes de assumir. Ao completar seção documental → listar REQ-IDs cobertos e confirmar `traceability.md`.
