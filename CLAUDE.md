# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Critical constraint: documentation-only repository

This repository (`FGR-Ops-Requisitos`) is **exclusively** for PRD, SPEC, and architecture documentation. **Do not create or edit product source code** (`.ts`, `.prisma`, `.tsx`, controllers, use-cases, components, etc.) here. Tactical skills (`entity`, `controller`, `prisma`, etc.) in `.agent/skills/` serve as architectural reference for writing SPEC/PRD — not for implementation.

## OpsX workflow (change management)

All documentation changes follow the OpsX pipeline via skills in `.agent/skills/`:

| Skill / Alias | Purpose |
|---|---|
| `/opsx:explore` | Think, map, and explore ideas against `docs/` — no silent edits |
| `/opsx:propose` | Create `docs/changes/<kebab-name>/` with `proposal.md`, `design.md`, `tasks.md` |
| `/opsx:apply` | Execute tasks: edit PRD, SPEC, `docs/traceability.md`; run consistency check |
| `/opsx:archive` | Archive completed change folder |

Change packages live under `docs/changes/<kebab-name>/` (excluding `archive/`). There is **no OpenSpec CLI**.

After every `/opsx:apply` session run the consistency check:

```bash
python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py
```

## Documentation structure

`docs/` is the single source of truth. Root-level `PRD-FGR-OPS.md` and `FGR-OPS-SPEC.md` are stubs pointing to `docs/`.

| Path | Content |
|---|---|
| `docs/PRD/_index.md` | PRD index and REQ-ID registry |
| `docs/SPEC/_index.md` | SPEC index and architecture overview |
| `docs/traceability.md` | **Global matrix** — must be updated whenever PRD/SPEC changes |
| `docs/flows/` | Mermaid operational diagrams |
| `docs/audit/decisions-log.md` | Architectural decisions (DEC-001…) |
| `docs/changes/` | Active change packages (OpsX) |
| `docs/INFRA.md` | Infrastructure and environment setup |
| `docs/UI-DESIGN.md` | Design system and visual specifications |

## Identifier conventions

- **PRD requirements:** `REQ-<PREFIX>-<NNN>` — prefixes: `FUNC`, `NFR`, `ACE`, `RBAC`, `JOR`, `CTX`, `OBJ`, `MET`, `RISK`
- **SPEC traceability blocks:** every SPEC section referencing PRD requirements must include a `**Rastreio PRD:**` line listing `REQ-xxx` IDs
- **Architecture decisions:** `DEC-<NNN>` in `docs/audit/decisions-log.md`; architectural ADRs in SPEC use `D1–D7`
- **Cross-links:** PRD → SPEC: `→ SPEC: relative-path#anchor`; SPEC → PRD: `Rastreio PRD:` block

Updating `docs/traceability.md` is a **mandatory deliverable** whenever PRD or SPEC edits from a change are stable.

## Project context (FGR-OPS)

**FGR-OPS** is a multi-tenant construction operations platform for FGR Incorporações. The MVP delivers the **Machinery Link** module — a digital system for requesting, dispatching, executing, and tracking heavy machinery across construction sites.

### Planned tech stack (for spec authoring context)

- **Frontend:** Angular 20 PWA (mobile-first, single codebase for all profiles)
- **Backend:** NestJS 10+ REST, Turborepo monorepo, pnpm 9.x
- **Database:** SQL Server 2019+ via Prisma ORM (logical multi-tenancy via `obraId`)
- **Auth:** JWT access (15 min) + refresh (7 days / 12h field), Redis blacklist, RBAC

### Core architecture decisions (D1–D7)

| ADR | Decision |
|---|---|
| D1 | Turborepo monorepo — shared DTOs between Angular and NestJS |
| D2 | SQL Server + Prisma ORM |
| D3 | JWT + Redis blacklist + rate limiting |
| D4 | Logical multi-tenancy: `obraId` on all business tables |
| D5 | SuperAdmin/Board bypass tenant filter; all cross-tenant access audited |
| D6 | Field profiles (Empreiteiro, Operador): 6-digit PIN; Admin: strong password, 180-day rotation |
| D7 | Angular 20.x as baseline; validate latest patch at dependency lock time |

### Key domain concepts

- **Demanda** — aggregate root for machinery requests; states: `PENDENTE → EM_ANDAMENTO → CONCLUIDA / CANCELADA / RETORNADA`; also `AGENDADA → PENDENTE_APROVACAO`
- **Queue engine** — hard filter by sector/equipment compatibility, then multivalued scoring: `score = (W_adj × adjacency) + (W_srv × service_priority) + (W_mat × material_risk)`; default weights 50/30/20; ties broken by FIFO
- **SLA levels:** MAXIMA (15 min), ELEVADA (45 min), NORMAL (120 min); timeout → `PENDENTE_APROVACAO` → auto-close EOD
- **`exigeTransporte` flag** on `Servico` entity mandates origin→destination fields on demand creation
