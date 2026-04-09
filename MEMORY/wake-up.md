# MEMORY/wake-up.md — Estado da Documentação

> Leia este arquivo no início de cada sessão para retomar contexto.

**Atualizado em:** 2026-04-09 (inicialização do pipeline neuro-simbólico)

---

## Estado Atual do Projeto

### PRD — 7 módulos estáveis

| Módulo | Arquivo | REQ-IDs Principais |
|--------|---------|---------------------|
| Visão e escopo | `docs/PRD/00-visao-escopo.md` | CTX-001…003, OBJ-001…005, SCO-001…005, SCO-F2-001…006, SCO-GAT-001…004 |
| Usuários e RBAC | `docs/PRD/01-usuarios-rbac.md` | RBAC-001…006 |
| Jornada do usuário | `docs/PRD/02-jornada-usuario.md` | JOR-001…005 |
| Requisitos funcionais | `docs/PRD/03-requisitos-funcionais.md` | FUNC-001…010 |
| Requisitos não funcionais | `docs/PRD/04-requisitos-nao-funcionais.md` | NFR-001…007 |
| Critérios de aceite | `docs/PRD/05-criterios-aceite.md` | ACE-001…006, ACE-008 |
| Métricas e riscos | `docs/PRD/06-metricas-riscos.md` | MET-001…003, RISK-001…002 |

### SPEC — 9 módulos + UI-DESIGN.md estáveis

| Módulo | Arquivo |
|--------|---------|
| Visão e arquitetura | `docs/SPEC/00-visao-arquitetura.md` |
| Módulos da plataforma | `docs/SPEC/01-modulos-plataforma.md` |
| Modelo de dados | `docs/SPEC/02-modelo-dados.md` |
| Fila, scoring, estados, SLA | `docs/SPEC/03-fila-scoring-estados-sla.md` |
| RBAC e permissões | `docs/SPEC/04-rbac-permissoes.md` |
| Backlog MVP e glossário | `docs/SPEC/05-backlog-mvp-glossario.md` |
| Definições complementares | `docs/SPEC/06-definicoes-complementares.md` |
| Design UI e lógica | `docs/SPEC/07-design-ui-logica.md` |
| Contratos de API REST | `docs/SPEC/08-api-contratos.md` |
| Design system | `docs/UI-DESIGN.md` |

---

## Últimas Decisões Registradas

| DEC | Título | Estado |
|-----|--------|--------|
| DEC-001 | Regra Zero vs filtros (`operadorAlocadoId`) | Decidido |
| DEC-002 | Cancelamento automático vs revisão administrativa | Decidido |
| DEC-003 | Fonte canónica para `REQ-MET-002` | Decidido |
| DEC-004 | Política de autenticação segmentada por perfil | Decidido |
| DEC-005 | Localização obrigatória na abertura de demanda | Decidido |
| DEC-006 | Revisão do escopo de transporte de material no MVP | Decidido |
| DEC-007 | Stack de frontend web: Angular 20 (PWA) | Decidido |
| DEC-008 | Paradigma Zoneless e Signals (Angular 20) | Decidido |
| DEC-009 | Reintrodução de `exigeTransporte` no MVP | Decidido |
| DEC-010 | Modelo de cadastro de TipoMaquinario e Maquinario | Decidido |

**Próxima DEC disponível: DEC-011**

---

## Pacotes OpsX Ativos

Nenhum pacote ativo — `docs/changes/` contém apenas `archive/` e `README.md`.

---

## Cobertura de Rastreabilidade (baseline 2026-03-26)

- **Total REQ-IDs:** ~62 cobertos, 2 parciais, 0 não cobertos
- **Auditoria:** 37 achados, todos resolvidos (7 bloqueantes + 28 importantes + 2 menores)
- **Detalhe:** `docs/audit/output/global/consolidated-global.json`

---

## Alertas e Pendências

- Nenhum alerta crítico ativo
- Verificar `MEMORY/inbox.md` para tarefas documentais pendentes

---

## Referências Rápidas

- [Índice PRD](docs/PRD/_index.md)
- [Índice SPEC](docs/SPEC/_index.md)
- [Traceability](docs/traceability.md)
- [Decisions Log](docs/audit/decisions-log.md)
- [Changes](docs/changes/)
- [MEMORY/inbox.md](MEMORY/inbox.md)
