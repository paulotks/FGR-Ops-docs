# Etapa 0 — Mapeamento M01–M07 (PRD ↔ SPEC)

Artefacto gerado a partir de [docs/PRD/_index.md](../PRD/_index.md) e [docs/SPEC/_index.md](../SPEC/_index.md), com **notas de SPEC secundário** alinhadas à [matriz global](../traceability.md).

| `module_id` | Título (PRD) | `prd_path` | SPEC principal (`spec_path`) | SPEC adicional (paridade PRD ou matriz) | Nota |
|-------------|--------------|------------|--------------------------------|----------------------------------------|------|
| M01 | Visão e escopo | `docs/PRD/00-visao-escopo.md` | `docs/SPEC/00-visao-arquitetura.md` | `docs/SPEC/05-backlog-mvp-glossario.md` | Matriz: `REQ-SCO-F2-*`, `REQ-SCO-GAT-*` em 05 (backlog Fase 2 e gatilhos). |
| M02 | Personas e RBAC | `docs/PRD/01-usuarios-rbac.md` | `docs/SPEC/04-rbac-permissoes.md` | — | Paridade 1:1; sem secundário obrigatório na matriz. |
| M03 | Jornada | `docs/PRD/02-jornada-usuario.md` | `docs/SPEC/01-modulos-plataforma.md` | `docs/SPEC/03-fila-scoring-estados-sla.md` | PRD lista 01+03; matriz: `REQ-JOR-001`→01; `REQ-JOR-002`…`005`→03 (triagem, score, campo). |
| M04 | Requisitos funcionais | `docs/PRD/03-requisitos-funcionais.md` | `docs/SPEC/03-fila-scoring-estados-sla.md` | `01-modulos-plataforma`, `02-modelo-dados`, `06-definicoes-complementares` | Núcleo operacional em 03; `REQ-FUNC-*` repartidos na matriz por 01/02/06. |
| M05 | RNF | `docs/PRD/04-requisitos-nao-funcionais.md` | `docs/SPEC/00-visao-arquitetura.md` | `02-modelo-dados`, `06-definicoes-complementares` | PRD paridade 00+02+06; matriz detalha `REQ-NFR-*` por ficheiro. |
| M06 | Critérios de aceite | `docs/PRD/05-criterios-aceite.md` | `04-rbac-permissoes` **e** `03-fila-scoring-estados-sla` (dois núcleos) | `docs/SPEC/00-visao-arquitetura.md` | Matriz: `REQ-ACE-007`→00 (token); restantes em 04/03 conforme matriz. |
| M07 | Métricas e riscos | `docs/PRD/06-metricas-riscos.md` | `03-fila-scoring-estados-sla` **e** `05-backlog-mvp-glossario` (dois núcleos) | `02-modelo-dados`, `06-definicoes-complementares` | Matriz: `REQ-MET-*`→03+06; `REQ-RISK-*`→05+06; índices também citam 02. |

Caminhos completos dos SPEC adicionais em M04: `docs/SPEC/01-modulos-plataforma.md`, `docs/SPEC/02-modelo-dados.md`, `docs/SPEC/06-definicoes-complementares.md`.

**JSON máquina-legível:** [step0-module-mapping.json](step0-module-mapping.json).

**Próxima etapa:** [Etapa 1 — Execução por módulo (`ANALISAR Mxx`)](step1-per-module-audit.md).

[Voltar ao README dos docs](../README.md)
