# Índice mestre — PRD FGR-Ops

Pacote modular de requisitos de produto. Resumos abaixo; conteúdo migrado a partir de `PRD-FGR-OPS.md` (ficheiros restantes ainda em migração).

| Ficheiro | Domínio | Resumo | IDs principais | SPEC (paridade) |
|----------|---------|--------|----------------|-----------------|
| [00-visao-escopo.md](00-visao-escopo.md) | Visão e escopo | Secções 1–3 do PRD: contexto, objetivos, escopo MVP/Fase 2 e gatilhos. | REQ-CTX-001…003, REQ-OBJ-001…005, REQ-SCO-001…005, REQ-SCO-F2-001…006, REQ-SCO-GAT-001…004 | [00-visao-arquitetura.md](../SPEC/00-visao-arquitetura.md) |
| [01-usuarios-rbac.md](01-usuarios-rbac.md) | Personas e RBAC | Perfis do produto, escopos de atuação e permissões-base por papel. | REQ-RBAC-001…006 | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md) |
| [02-jornada-usuario.md](02-jornada-usuario.md) | Jornada | Fluxo operacional do Machinery Link: requisição, triagem logística, score, execução em campo e auditoria administrativa. | REQ-JOR-001…005 | [01-modulos-plataforma.md](../SPEC/01-modulos-plataforma.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md) |
| [03-requisitos-funcionais.md](03-requisitos-funcionais.md) | Requisitos funcionais | Requisitos funcionais do MVP operacional: estados, filtros, expediente, alocação manual, cronómetros e cancelamentos. | REQ-FUNC-001…010 | [01-modulos-plataforma.md](../SPEC/01-modulos-plataforma.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md) |
| [04-requisitos-nao-funcionais.md](04-requisitos-nao-funcionais.md) | RNF | Stack base, PWA mobile-first, persistencia multi-tenant e politicas de autenticacao/seguranca. | REQ-NFR-001…007 | [00-visao-arquitetura.md](../SPEC/00-visao-arquitetura.md), [02-modelo-dados.md](../SPEC/02-modelo-dados.md), [06-definicoes-complementares.md](../SPEC/06-definicoes-complementares.md) |
| [05-criterios-aceite.md](05-criterios-aceite.md) | Critérios de aceite | Critérios testáveis do PRD para RBAC, isolamento e operação do Machinery Link; segurança de token permanece pendente. | REQ-ACE-001…006, REQ-ACE-008 | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md) |
| [06-metricas-riscos.md](06-metricas-riscos.md) | Metricas e riscos | Indicadores de sucesso do MVP, riscos operacionais e mitigacoes para rollout em campo. | REQ-MET-001…003, REQ-RISK-001…002 | [02-modelo-dados.md](../SPEC/02-modelo-dados.md), [03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md), [05-backlog-mvp-glossario.md](../SPEC/05-backlog-mvp-glossario.md), [06-definicoes-complementares.md](../SPEC/06-definicoes-complementares.md) |

- [Matriz de rastreabilidade](../traceability.md)

[Voltar ao README dos docs](../README.md)
