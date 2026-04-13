# Índice mestre — PRD FGR-Ops

Pacote modular de requisitos de produto. Resumos abaixo; conteúdo migrado a partir de `PRD-FGR-OPS.md`


| Arquivo                                                            | Domínio               | Resumo                                                                                                                   | IDs principais                                                                             | SPEC (paridade)                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------ | --------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [00-visao-escopo.md](00-visao-escopo.md)                           | Visão e escopo        | Seções 1–3 do PRD: contexto, objetivos, escopo MVP/Fase 2 e gatilhos.                                                   | REQ-CTX-001…003, REQ-OBJ-001…005, REQ-SCO-001…005, REQ-SCO-F2-001…006, REQ-SCO-GAT-001…004 | [00-visao-arquitetura.md](../SPEC/00-visao-arquitetura.md)                                                                                                                                                                                                                 |
| [01-usuarios-rbac.md](01-usuarios-rbac.md)                         | Personas e RBAC       | Perfis do produto, escopos de atuação e permissões-base por papel.                                                       | REQ-RBAC-001…006                                                                           | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md)                                                                                                                                                                                                                     |
| [02-jornada-usuario.md](02-jornada-usuario.md)                     | Jornada               | Fluxo operacional do Machinery Link: requisição, triagem logística, score, execução em campo e auditoria administrativa. | REQ-JOR-001…005                                                                            | [01-modulos-plataforma.md](../SPEC/01-modulos-plataforma.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md)                                                                                                                                     |
| [03-requisitos-funcionais.md](03-requisitos-funcionais.md)         | Requisitos funcionais | Requisitos funcionais do MVP operacional: estados, filtros, expediente, alocação manual, cronómetros, cancelamentos, CRUD de Empreiteira e notificação de demanda para operador com fila vazia. | REQ-FUNC-001…013                                                                           | [01-modulos-plataforma.md](../SPEC/01-modulos-plataforma.md), [02-modelo-dados.md](../SPEC/02-modelo-dados.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md), [08-api-contratos.md](../SPEC/08-api-contratos.md)                               |
| [04-requisitos-nao-funcionais.md](04-requisitos-nao-funcionais.md) | RNF                   | Stack base, PWA mobile-first, persistência multi-tenant e políticas de autenticação/segurança.                           | REQ-NFR-001…007                                                                            | [00-visao-arquitetura.md](../SPEC/00-visao-arquitetura.md), [02-modelo-dados.md](../SPEC/02-modelo-dados.md), [06-definicoes-complementares.md](../SPEC/06-definicoes-complementares.md)                                                                                   |
| [05-criterios-aceite.md](05-criterios-aceite.md)                   | Critérios de aceite   | Critérios testáveis do PRD para RBAC, isolamento e operação do Machinery Link; segurança de token permanece pendente.    | REQ-ACE-001…006, REQ-ACE-008, REQ-ACE-009                                                  | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md)                                                                                                                                           |
| [06-metricas-riscos.md](06-metricas-riscos.md)                     | Métricas e riscos     | Indicadores de sucesso do MVP, riscos operacionais e mitigações para rollout em campo.                                   | REQ-MET-001…003, REQ-RISK-001…002                                                          | [02-modelo-dados.md](../SPEC/02-modelo-dados.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md), [05-backlog-mvp-glossario.md](../SPEC/05-backlog-mvp-glossario.md), [06-definicoes-complementares.md](../SPEC/06-definicoes-complementares.md) |


- [Matriz de rastreabilidade](../traceability.md)

[Voltar ao README dos docs](../README.md)

---

## Registro completo de REQ-IDs

> Seção machine-readable para o hook de rastreabilidade. Expansão explícita de todos os IDs registrados neste índice.

**Visão e escopo (`00-visao-escopo.md`):**
REQ-CTX-001, REQ-CTX-002, REQ-CTX-003,
REQ-OBJ-001, REQ-OBJ-002, REQ-OBJ-003, REQ-OBJ-004, REQ-OBJ-005,
REQ-SCO-001, REQ-SCO-002, REQ-SCO-003, REQ-SCO-004, REQ-SCO-005,
REQ-SCO-F2-001, REQ-SCO-F2-002, REQ-SCO-F2-003, REQ-SCO-F2-004, REQ-SCO-F2-005, REQ-SCO-F2-006,
REQ-SCO-GAT-001, REQ-SCO-GAT-002, REQ-SCO-GAT-003, REQ-SCO-GAT-004

**Usuários e RBAC (`01-usuarios-rbac.md`):**
REQ-RBAC-001, REQ-RBAC-002, REQ-RBAC-003, REQ-RBAC-004, REQ-RBAC-005, REQ-RBAC-006

**Jornada do usuário (`02-jornada-usuario.md`):**
REQ-JOR-001, REQ-JOR-002, REQ-JOR-003, REQ-JOR-004, REQ-JOR-005

**Requisitos funcionais (`03-requisitos-funcionais.md`):**
REQ-FUNC-001, REQ-FUNC-002, REQ-FUNC-003, REQ-FUNC-004, REQ-FUNC-005,
REQ-FUNC-006, REQ-FUNC-007, REQ-FUNC-008, REQ-FUNC-009, REQ-FUNC-010,
REQ-FUNC-011, REQ-FUNC-012, REQ-FUNC-013

**Requisitos não funcionais (`04-requisitos-nao-funcionais.md`):**
REQ-NFR-001, REQ-NFR-002, REQ-NFR-003, REQ-NFR-004, REQ-NFR-005, REQ-NFR-006, REQ-NFR-007

**Critérios de aceite (`05-criterios-aceite.md`):**
REQ-ACE-001, REQ-ACE-002, REQ-ACE-003, REQ-ACE-004, REQ-ACE-005, REQ-ACE-006, REQ-ACE-007, REQ-ACE-008, REQ-ACE-009

**Métricas e riscos (`06-metricas-riscos.md`):**
REQ-MET-001, REQ-MET-002, REQ-MET-003,
REQ-RISK-001, REQ-RISK-002