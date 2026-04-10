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
| `REQ-CTX-*`, `REQ-OBJ-*`, `REQ-SCO-*` | [PRD/00-visao-escopo.md](PRD/00-visao-escopo.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md), [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md) | Contexto, objetivos, escopo MVP/Fase 2 e alinhamento arquitetural base. Fronteira FGR Ops (plataforma) ↔ Machinery Link (módulo) e sequência canônica de bootstrapping de obra formalizadas em SPEC/01 (DEC-014). |
| `REQ-SCO-F2-*`, `REQ-SCO-GAT-*` | [PRD/00-visao-escopo.md](PRD/00-visao-escopo.md) | [SPEC/05-backlog-mvp-glossario.md](SPEC/05-backlog-mvp-glossario.md) | Delimitacao do backlog, itens adiados e gatilhos de promocao. |
| `REQ-RBAC-*` | [PRD/01-usuarios-rbac.md](PRD/01-usuarios-rbac.md) | [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md), [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md) | Perfis, escopos de acesso, bypass cross-tenant e matrizes de permissao. Posicionamento arquitetural dos perfis em camadas (plataforma FGR Ops vs módulo Machinery Link) formalizado em SPEC/01 (DEC-014). |
| `REQ-JOR-001` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md), [SPEC/07-design-ui-logica.md](SPEC/07-design-ui-logica.md) | Cobertura da abertura de demandas, localizacao obrigatoria (Quadra/Lote ou Local Externo), filtragem mutua Servico/Maquinario, material e destino opcionais, descricao para movimentacao (DEC-005, DEC-006); fluxo de cancelamento proprio em `PENDENTE` adicionado em SPEC/07 (DEC-013). |
| `REQ-JOR-002`, `REQ-JOR-003` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Triagem por jurisdicao e score operacional. |
| `REQ-JOR-004`, `REQ-JOR-005` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Execucao em campo, alocacao manual e auditoria administrativa. |
| `REQ-FUNC-001`, `REQ-FUNC-002` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/08-api-contratos.md](SPEC/08-api-contratos.md) | Maquina de estados, filtros eliminatorios e regras de fila. Endpoints de configuração de pesos (`PATCH /obras/:id/configuracoes`), recálculo forçado (`POST /obras/:id/fila/recalcular`) e kanban administrativo (`GET /obras/:id/fila`) adicionados em SPEC/08. |
| `REQ-FUNC-003` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md), [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md), [SPEC/08-api-contratos.md](SPEC/08-api-contratos.md) | Cadastro de TipoMaquinario (nome, descricao), Maquinario (`proprietarioTipo` + `empreiteiraId` — DEC-016 supercede `empresaProprietaria` de DEC-010), servicos, ajudantes e operadores; CRUD APIs e permissoes adicionadas. |
| `REQ-FUNC-012` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md), [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md), [SPEC/08-api-contratos.md](SPEC/08-api-contratos.md) | CRUD de `Empreiteira` (entidade global, sem `obraId`); vínculo `User.empreiteiraId` para perfil Empreiteiro; discriminador `proprietarioTipo` em Maquinario. DEC-016. |
| `REQ-FUNC-004` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md), [SPEC/08-api-contratos.md](SPEC/08-api-contratos.md) | Expediente, assistencia offline, checkpoint manual e rastreabilidade de ajudantes. Contratos de check-in (`POST /operadores/:id/checkin`) e checkout (`POST /operadores/:id/checkout`) adicionados em SPEC/08; erros OPR-003..OPR-005 formalizados. |
| `REQ-FUNC-005` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Agrupamento e criacao multipla. |
| `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-009` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Agendamentos, cronometros, destaque visual e tratamento de cancelamentos. |
| `REQ-FUNC-011` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/07-design-ui-logica.md](SPEC/07-design-ui-logica.md) | Pausa de demanda em andamento (MVP): estado `PAUSADA`, transicoes `pausar`/`retomar` formalizadas em SPEC/03, justificativa obrigatoria, SLA continua correndo. DEC-011 registrado. |
| `REQ-FUNC-010` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Modelagem espacial, adjacencias e suporte ao motor de score. `Quadra` possui FK `setorOperacionalId` obrigatória (DEC-015); `Rua` permanece descritiva/nullable (DEC-012). |
| `REQ-NFR-001`, `REQ-NFR-003` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Monorepo, stack base, backend e decisoes arquiteturais. |
| `REQ-NFR-002` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md), [SPEC/07-design-ui-logica.md](SPEC/07-design-ui-logica.md) | PWA mobile-first em Angular 20; hierarquia de telas, Zoneless/Signals e padroes de componentes em 07; alinhado a DEC-007, DEC-008 e ADR D7. Design system e especificacoes de telas em [UI-DESIGN.md](UI-DESIGN.md). |
| `REQ-NFR-004` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Persistencia relacional e isolamento multi-tenant. |
| `REQ-NFR-005`, `REQ-NFR-006` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | JWT, refresh tokens e rate limiting. |
| `REQ-NFR-007` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md#politica-autenticacao-senha](SPEC/00-visao-arquitetura.md#politica-autenticacao-senha) | Politica de autenticacao segmentada por perfil (D6/DEC-004): Campo (Usuario+PIN) e Administrativo (palavra-passe forte). |
| `REQ-ACE-001`, `REQ-ACE-008` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md) | Isolamento RBAC e auditoria cross-tenant. |
| `REQ-ACE-002`, `REQ-ACE-003`, `REQ-ACE-004`, `REQ-ACE-005`, `REQ-ACE-006` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/07-design-ui-logica.md](SPEC/07-design-ui-logica.md) | Aceites ligados a estados, score, alocacao manual, UI e cancelamentos; `REQ-ACE-006` tambem coberto em SPEC/07 (fluxo de cancelamento do Empreiteiro na UI — DEC-013). |
| `REQ-ACE-007` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Seguranca de token; cobertura marcada como alinhada a arquitetura base. |
| `REQ-MET-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Medicao de SLA, atendimento e operacao em campo. |
| `REQ-RISK-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/05-backlog-mvp-glossario.md](SPEC/05-backlog-mvp-glossario.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Riscos de rollout, conectividade e limites do MVP. |

## Resultados da auditoria PRD ↔ SPEC

Resumo agregado de 7 modulos auditados (actualizado em 2026-03-26, pos-Fase 3 — revalidacao global; rastreabilidade de UI-DESIGN.md e SPEC/07 adicionada).

| Metrica | Valor |
|---------|-------|
| Total achados | 37 |
| Bloqueantes | 7 (todos resolvidos) |
| Importantes | 28 (todos resolvidos) |
| Menores | 2 (todos resolvidos) |
| Resolvidos | 37 |
| Coberto | 62 |
| Parcial | 2 |
| Nao coberto | 0 |

Detalhes por modulo e JSON global em [docs/audit/output/global/consolidated-global.json](audit/output/global/consolidated-global.json).

### Cobertura por modulo (todos os achados resolvidos)

| Modulo | Achados (B/I/m) | Coberto | Parcial | Decisoes-chave |
|--------|-----------------|---------|---------|----------------|
| M01 — Visao & Escopo | 1 / 4 / 0 | 21 | 2 | Fases 1.3, 2.2–2.6 |
| M02 — RBAC | 0 / 2 / 2 | 6 | 0 | Fase 2.6, 3 |
| M03 — Jornada | 0 / 4 / 0 | 5 | 0 | DEC-002, DEC-005, DEC-006; Fases 1.2, 2.1, 2.4, 2.6 |
| M04 — Req. Funcionais | 1 / 6 / 0 | 10 | 0 | DEC-001; Fases 1.1, 2.1, 2.4, 2.6 |
| M05 — Req. Nao Funcionais | 1 / 2 / 0 | 7 | 0 | DEC-004; Fases 1.4, 2.2, 2.5 |
| M06 — Criterios de Aceite | 2 / 5 / 0 | 8 | 0 | DEC-001, DEC-002; Fases 1.1, 1.2, 2.1, 2.6 |
| M07 — Metricas & Riscos | 2 / 4 / 0 | 5 | 0 | DEC-003; Fases 1.5, 2.3, 2.4, 2.6 |

B = Bloqueante · I = Importante · m = Menor

---

## Referencias

- [README dos docs](README.md)
- [Indice mestre PRD](PRD/_index.md)
- [Indice mestre SPEC](SPEC/_index.md)
- [JSON global consolidado](audit/output/global/consolidated-global.json)
