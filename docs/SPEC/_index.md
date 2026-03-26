# Índice mestre — SPEC FGR-Ops

Pacote modular de especificação técnica. Resumos abaixo; conteúdo migrado a partir de `FGR-OPS-SPEC.md` (arquivos restantes ainda em migração).

| Arquivo | Domínio | Resumo | Rastreio PRD (principal) | IDs técnicos |
|----------|---------|--------|--------------------------|--------------|
| [00-visao-arquitetura.md](00-visao-arquitetura.md) | Visão e arquitetura | Seções 1–2 da SPEC: visão geral, princípios, monorepo, ADRs (JWT, multi-tenant, bypass Board) e DDD tático. | REQ-CTX-001…003, REQ-OBJ-001…005, REQ-SCO-001…005 | — |
| [01-modulos-plataforma.md](01-modulos-plataforma.md) | Módulos Core / Machinery Link | Fronteiras entre `Core` e `Machinery Link`, atores, capacidades principais e dependências do domínio operacional. | REQ-JOR-001, REQ-JOR-004, REQ-FUNC-003…005, REQ-FUNC-010 | — |
| [02-modelo-dados.md](02-modelo-dados.md) | Modelo de dados | Entidades, relações de integridade, escopo por obra e lacunas resolvidas do domínio operacional. | REQ-FUNC-003, REQ-FUNC-004, REQ-FUNC-006, REQ-FUNC-007, REQ-FUNC-010, REQ-NFR-004 | — |
| [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md) | Fila, scoring, estados, SLA | Motor operacional da fila: filtros, score, governança de pesos, SLAs, transições de estado e cancelamentos mediados. | REQ-JOR-002…005, REQ-FUNC-001…002, REQ-FUNC-004, REQ-FUNC-006…010, REQ-ACE-002…006 | — |
| [04-rbac-permissoes.md](04-rbac-permissoes.md) | RBAC e permissões | Perfis, regras de isolamento, bypass cross-tenant e matrizes completas de autorização. | REQ-RBAC-001…006, REQ-ACE-001, REQ-ACE-008 | *opcional TECH-RBAC-* |
| [05-backlog-mvp-glossario.md](05-backlog-mvp-glossario.md) | Backlog MVP e glossário | Delimitação do MVP, itens adiados para Fase 2 e glossário técnico comum. | REQ-SCO-F2-001…006, REQ-RISK-001 | — |
| [06-definicoes-complementares.md](06-definicoes-complementares.md) | Definições complementares | Offline PWA, comportamento de agendamentos, adiamento de `ServicoDinamico` e rastreabilidade de ajudantes. | REQ-NFR-002, REQ-FUNC-004, REQ-FUNC-006, REQ-FUNC-009, REQ-RISK-002, REQ-MET-003 | — |
| [07-design-ui-logica.md](07-design-ui-logica.md) | Lógica e UX | Hierarquia de Telas (Empreiteiro, Operador, Supervisor), mapeamento visual e Angular 20. | REQ-JOR-001 | — |

- [Matriz de rastreabilidade](../traceability.md)

[Voltar ao README dos docs](../README.md)
