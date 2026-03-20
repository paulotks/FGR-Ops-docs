# Matriz de Rastreabilidade

Matriz global de rastreio entre os requisitos do PRD e os modulos da SPEC.

## Como ler

- `REQ / grupo`: faixa de IDs ou agrupamento funcional mantido no PRD.
- `PRD`: modulo funcional onde o requisito e mantido.
- `SPEC`: modulo tecnico principal que cobre o requisito.
- `Notas`: observacoes sobre cobertura, transversalidade ou dependencias.

## Matriz global

| REQ / grupo | PRD | SPEC | Notas |
|-------------|-----|------|-------|
| `REQ-CTX-*`, `REQ-OBJ-*`, `REQ-SCO-*` | [PRD/00-visao-escopo.md](PRD/00-visao-escopo.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Contexto, objetivos, escopo MVP/Fase 2 e alinhamento arquitetural base. |
| `REQ-SCO-F2-*`, `REQ-SCO-GAT-*` | [PRD/00-visao-escopo.md](PRD/00-visao-escopo.md) | [SPEC/05-backlog-mvp-glossario.md](SPEC/05-backlog-mvp-glossario.md) | Delimitacao do backlog, itens adiados e gatilhos de promocao. |
| `REQ-RBAC-*` | [PRD/01-usuarios-rbac.md](PRD/01-usuarios-rbac.md) | [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md) | Perfis, escopos de acesso, bypass cross-tenant e matrizes de permissao. |
| `REQ-JOR-001` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md) | Cobertura da abertura de demandas e fronteiras do modulo operacional. |
| `REQ-JOR-002`, `REQ-JOR-003` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Triagem por jurisdicao e score operacional. |
| `REQ-JOR-004`, `REQ-JOR-005` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Execucao em campo, alocacao manual e auditoria administrativa. |
| `REQ-FUNC-001`, `REQ-FUNC-002` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Maquina de estados, filtros eliminatorios e regras de fila. |
| `REQ-FUNC-003` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Cadastro de maquinario, ajudantes, operadores e entidades operacionais. |
| `REQ-FUNC-004` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Expediente, assistencia offline, checkpoint manual e rastreabilidade de ajudantes. |
| `REQ-FUNC-005` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Agrupamento e criacao multipla. |
| `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-009` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Agendamentos, cronometros, destaque visual e tratamento de cancelamentos. |
| `REQ-FUNC-010` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Modelagem espacial, adjacencias e suporte ao motor de score. |
| `REQ-NFR-001`, `REQ-NFR-003` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Monorepo, stack base, backend e decisoes arquiteturais. |
| `REQ-NFR-002` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Experiencia PWA mobile-first, conectividade e operacao offline. |
| `REQ-NFR-004` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Persistencia relacional e isolamento multi-tenant. |
| `REQ-NFR-005`, `REQ-NFR-006`, `REQ-NFR-007` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | JWT, refresh tokens, rate limiting e politicas de autenticacao. |
| `REQ-ACE-001`, `REQ-ACE-008` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md) | Isolamento RBAC e auditoria cross-tenant. |
| `REQ-ACE-002`, `REQ-ACE-003`, `REQ-ACE-004`, `REQ-ACE-005`, `REQ-ACE-006` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Aceites ligados a estados, score, alocacao manual, UI e cancelamentos. |
| `REQ-ACE-007` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Seguranca de token; cobertura marcada como alinhada a arquitetura base. |
| `REQ-MET-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Medicao de SLA, atendimento e operacao em campo. |
| `REQ-RISK-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/05-backlog-mvp-glossario.md](SPEC/05-backlog-mvp-glossario.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Riscos de rollout, conectividade e limites do MVP. |

## Referencias

- [README dos docs](README.md)
- [Indice mestre PRD](PRD/_index.md)
- [Indice mestre SPEC](SPEC/_index.md)
