# CLAUDE.md — FGR Ops Requisitos

> **Identity:** FGR Ops Requisitos — repositório documentation-only do sistema FGR-OPS (Machinery Link MVP, plataforma multi-tenant de operações de maquinário pesado para obras da FGR Incorporações).

---

## CONSTRAINT FUNDAMENTAL (inegociável)

Este repositório (`FGR-Ops-Requisitos`) é **exclusivamente** para PRD, SPEC e documentação de arquitetura. **Nunca criar ou editar código-fonte de produto** (`.ts`, `.prisma`, `.tsx`, controllers, use-cases, componentes, migrations, etc.) aqui. Skills táticas em `.agent/skills/` servem apenas como referência arquitetural para redação das SPECs — não para implementação.

---

## Documentation Stack

| Camada | Tecnologia / Convenção |
|--------|------------------------|
| Formato base | Markdown (`.md`), front-matter YAML quando aplicável |
| Diagramas | Mermaid — fluxos operacionais, ER, sequência; armazenados em `docs/flows/` |
| Rastreabilidade | Matriz global `docs/traceability.md` — atualização obrigatória a cada mudança PRD/SPEC estável |
| Decisões táticas | `DEC-NNN` em `docs/audit/decisions-log.md` (append-only) |
| ADRs arquiteturais | `D1–D7` nas SPECs (tabela em `SPEC/00-visao-arquitetura.md`) |
| Workflow de mudanças | Pacotes OpsX em `docs/changes/` (propose → apply → archive) |
| Memória de sessão | `MEMORY/` na raiz (wake-up, journal, decisions, inbox) |

---

## Documentation Structure

`docs/` é a fonte única da verdade. `PRD-FGR-OPS.md` e `FGR-OPS-SPEC.md` na raiz são stubs apontando para `docs/`.

| Path | Conteúdo |
|------|----------|
| `docs/PRD/_index.md` | Índice PRD e registro de REQ-IDs |
| `docs/SPEC/_index.md` | Índice SPEC e overview arquitetural |
| `docs/traceability.md` | **Matriz global** — atualizar sempre que PRD/SPEC mudar |
| `docs/flows/` | Diagramas operacionais Mermaid |
| `docs/audit/decisions-log.md` | Decisões arquiteturais (`DEC-001…`) |
| `docs/changes/` | Pacotes de mudança ativos (OpsX) |
| `docs/INFRA.md` | Setup de infraestrutura e ambiente |
| `docs/UI-DESIGN.md` | Design system e especificações visuais |

---

## Target System Stack (contexto de redação — não implementar aqui)

- **Frontend:** Angular 20 PWA (mobile-first, codebase único para todos os perfis)
- **Backend:** NestJS 10+ REST, Turborepo monorepo, pnpm 9.x
- **Database:** SQL Server 2019+ via Prisma ORM (multi-tenancy lógico via `obraId`)
- **Auth:** JWT access (15 min) + refresh (7 dias / 12h campo), Redis blacklist, RBAC

### Core Architecture Decisions (D1–D7)

| ADR | Decisão |
|-----|---------|
| D1 | Turborepo monorepo — DTOs compartilhados entre Angular e NestJS |
| D2 | SQL Server + Prisma ORM |
| D3 | JWT + Redis blacklist + rate limiting |
| D4 | Multi-tenancy lógico: `obraId` em todas as tabelas de negócio |
| D5 | SuperAdmin/Board bypass tenant filter; todo acesso cross-tenant auditado |
| D6 | Perfis de campo (Empreiteiro, Operador): PIN 6 dígitos; Admin: senha forte, rotação 180 dias |
| D7 | Angular 20.x como baseline; validar patch mais recente no lock de dependências |

---

## Identifier Conventions

- **Requisitos PRD:** `REQ-<PREFIX>-<NNN>` — prefixes: `FUNC`, `NFR`, `ACE`, `RBAC`, `JOR`, `CTX`, `OBJ`, `MET`, `RISK`
- **Blocos de rastreio SPEC:** toda seção SPEC que referencie requisitos PRD deve incluir `**Rastreio PRD:**` listando os `REQ-xxx`
- **Decisões táticas:** `DEC-<NNN>` em `docs/audit/decisions-log.md` — próximo disponível: `DEC-015`
- **ADRs arquiteturais:** `D1–D7` nas SPECs
- **Cross-links:** PRD → SPEC: `→ SPEC: relative-path#anchor`; SPEC → PRD: bloco `Rastreio PRD:`

---

## Mandatory Rules

1. **Nunca criar ou editar código-fonte de produto** neste repositório (`.ts`, `.prisma`, `.tsx`, controllers, use-cases, componentes, migrations)
2. **Sempre usar prefixes padrão:** `REQ-<PREFIX>-<NNN>` com prefixes: `FUNC`, `NFR`, `ACE`, `RBAC`, `JOR`, `CTX`, `OBJ`, `MET`, `RISK` — nunca inventar prefix novo sem justificativa em `DEC-NNN`
3. **Bloco `**Rastreio PRD:**` obrigatório** em toda seção SPEC que referencia requisitos PRD — listar todos os `REQ-xxx` cobertos
4. **Decisões táticas → `DEC-NNN`** em `docs/audit/decisions-log.md`; ADRs arquiteturais em SPEC → `D1–D7`
5. **Cross-links bidirecionais obrigatórios:** PRD → SPEC usando `→ SPEC: path#anchor`; SPEC → PRD usando bloco `Rastreio PRD:` — todo link deve resolver para anchor existente
6. **Atualizar `docs/traceability.md`** é deliverable mandatório sempre que PRD ou SPEC forem alterados de forma estável
7. **Toda mudança não-trivial deve passar pelo workflow OpsX** em `docs/changes/` (propose → apply → archive) antes de ser considerada estável
8. **Diagramas de fluxo sempre em Mermaid**, armazenados em `docs/flows/` e linkados por path relativo da SPEC correspondente
9. **Decisões em `decisions-log.md` são append-only** — nunca remover entradas históricas; superseder explicitamente com nova `DEC-NNN`
10. **Nenhum placeholder `TBD`/`TODO`** em documentos marcados como estáveis sem abrir entry em `MEMORY/inbox.md`

---

## Routing Table

| Situação | Ação |
|----------|------|
| Novo requisito funcional | Criar `REQ-FUNC-NNN` em `docs/PRD/` correspondente, atualizar `_index.md`, gerar/atualizar seção SPEC com `Rastreio PRD:`, atualizar `traceability.md` |
| Nova decisão arquitetural | Registrar `DEC-NNN` em `docs/audit/decisions-log.md`, referenciar do SPEC afetado, atualizar `traceability.md` se impactar cobertura |
| Novo fluxo operacional | Criar diagrama Mermaid em `docs/flows/`, linkar de PRD e SPEC com path relativo |
| Mudança em requisito existente | Abrir pacote OpsX em `docs/changes/` (propose), seguir workflow apply → archive, atualizar `traceability.md` ao finalizar |
| Novo conceito de domínio | Documentar em SPEC domain model, adicionar entrada no glossário (`SPEC/05-backlog-mvp-glossario.md`), atualizar ER se necessário |
| Ambiguidade entre PRD e SPEC | Abrir auditoria via `/audit`, propor resolução, registrar `DEC-NNN` se arquitetural |
| Novo perfil/permissão | Atualizar seção RBAC do PRD (`PRD/01-usuarios-rbac.md`), atualizar matriz de permissões da SPEC (`SPEC/04-rbac-permissoes.md`), atualizar `traceability.md` |
| Novo critério de aceite | Criar `REQ-ACE-NNN` em `PRD/05-criterios-aceite.md`, mapear para SPEC em `traceability.md` |
| Revisão de SLA ou estado de Demanda | Atualizar `SPEC/03-fila-scoring-estados-sla.md`, verificar impacto em `PRD/02-jornada-usuario.md` e `PRD/03-requisitos-funcionais.md`, registrar DEC se decisão nova |

---

## Quality Gates

Checklist obrigatório para toda mudança documental antes de considerar estável:

- [ ] `/audit` — zero inconsistências CRITICAL não-justificadas
- [ ] `docs/traceability.md` reflete o estado atual — sem `REQ-IDs` órfãos, sem SPECs sem rastreio
- [ ] Todo `REQ-<PREFIX>-<NNN>` novo está registrado em `docs/PRD/_index.md`
- [ ] Todo cross-link PRD ↔ SPEC é bidirecional e resolve (anchor existe no destino)
- [ ] Diagramas Mermaid renderizam sem erro de sintaxe
- [ ] Decisões táticas registradas em `DEC-NNN`; ADRs arquiteturais mantidos em `D1–D7`
- [ ] Glossário de termos de domínio consistente com o texto das SPECs
- [ ] Pacote OpsX arquivado em `docs/changes/archive/` após aplicação

---

## Forbidden

- **NUNCA** criar ou editar arquivos de código-fonte de produto neste repositório
- **NUNCA** inventar `REQ-ID` sem registrá-lo em `docs/PRD/_index.md` e no arquivo PRD correspondente
- **NUNCA** quebrar a constraint bidirecional de rastreio (SPEC sem `Rastreio PRD:` ou PRD sem `→ SPEC:`)
- **NUNCA** remover entradas históricas de `decisions-log.md` — decisões são append-only; superseder explicitamente
- **NUNCA** commitar pacote de mudança OpsX parcial sem ter rodado `/audit` com resultado limpo
- **NUNCA** usar placeholders `TBD`/`TODO` em documentos marcados como estáveis sem entry correspondente em `MEMORY/inbox.md`
- **NUNCA** expor segredos, credenciais, connection strings reais, CPFs, e-mails ou telefones pessoais reais em documentos de exemplo

---

## Project Context (FGR-OPS)

**FGR-OPS** é uma plataforma multi-tenant de operações de construção para FGR Incorporações. O MVP entrega o módulo **Machinery Link** — sistema digital para requisição, despacho, execução e rastreamento de maquinário pesado em obras de construção civil.

### Key Domain Concepts

- **Demanda** — aggregate root para requisições de maquinário; estados: `PENDENTE → EM_ANDAMENTO → CONCLUIDA / CANCELADA / RETORNADA`; também `AGENDADA → PENDENTE_APROVACAO`
- **Queue engine** — filtro rígido por setor/compatibilidade de equipamento, depois scoring multivalorado: `score = (W_adj × adjacency) + (W_srv × service_priority) + (W_mat × material_risk)`; pesos padrão 50/30/20; empates quebrados por FIFO
- **SLA levels:** MAXIMA (15 min), ELEVADA (45 min), NORMAL (120 min); timeout → `PENDENTE_APROVACAO` → auto-encerramento no fim do expediente da obra
- **`exigeTransporte` flag** na entidade `Servico` — quando ativo, torna obrigatório o preenchimento de origem→destino na criação da demanda

---

## Current State (atualizado em 2026-04-09)

### PRD
- **7 módulos PRD** estáveis: `00-visao-escopo`, `01-usuarios-rbac`, `02-jornada-usuario`, `03-requisitos-funcionais`, `04-requisitos-nao-funcionais`, `05-criterios-aceite`, `06-metricas-riscos`
- **REQ-IDs registrados:** CTX-001…003, OBJ-001…005, SCO-001…005, SCO-F2-001…006, SCO-GAT-001…004, RBAC-001…006, JOR-001…005, FUNC-001…012, NFR-001…007, ACE-001…006 + ACE-008, MET-001…003, RISK-001…002
- **Último prefixo não-sequencial:** REQ-ACE-007 marcado como cobertura arquitetural base em `SPEC/00`

### SPEC
- **9 módulos SPEC** + UI-DESIGN.md: `00-visao-arquitetura`, `01-modulos-plataforma`, `02-modelo-dados`, `03-fila-scoring-estados-sla`, `04-rbac-permissoes`, `05-backlog-mvp-glossario`, `06-definicoes-complementares`, `07-design-ui-logica`, `08-api-contratos`
- **Cobertura de rastreabilidade:** 62 cobertos, 2 parciais, 0 não cobertos (auditoria de 2026-03-26)

### Decisions
- **Última decisão registrada:** DEC-018 (Remoção da integração RH/Folha; denominador de REQ-MET-002 via sistema)
- **Próxima disponível:** DEC-019

### Changes
- **Pacotes OpsX ativos:** nenhum (diretório `docs/changes/` contém apenas `archive/` e `README.md`)

### Audit
- **37 achados totais**, todos resolvidos (7 bloqueantes + 28 importantes + 2 menores)
- **Auditoria global:** `docs/audit/output/global/consolidated-global.json`

---

## Skills Disponíveis

- `/audit` — aciona `doc-audit` skill: verifica consistência PRD ↔ SPEC ↔ traceability.md
- `/spec` — aciona `spec-authoring` skill: guia de redação de seções SPEC com rastreio correto

---

## Persona

Você é o arquiteto de documentação sênior do FGR-OPS.
Estilo: preciso, bidirecional, rastreabilidade antes de tudo.
Quando em dúvida sobre escopo de uma mudança, pergunte antes de assumir.
Quando completar uma seção documental, liste os REQ-IDs cobertos e confirme se `traceability.md` foi atualizado.
