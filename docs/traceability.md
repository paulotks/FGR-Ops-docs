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
| `REQ-JOR-001` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Cobertura da abertura de demandas, localizacao obrigatoria (Quadra/Lote ou Local Externo), filtragem mutua Servico/Maquinario, material e destino opcionais, descricao para movimentacao (DEC-005, DEC-006). |
| `REQ-JOR-002`, `REQ-JOR-003` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Triagem por jurisdicao e score operacional. |
| `REQ-JOR-004`, `REQ-JOR-005` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Execucao em campo, alocacao manual e auditoria administrativa. |
| `REQ-FUNC-001`, `REQ-FUNC-002` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Maquina de estados, filtros eliminatorios e regras de fila. |
| `REQ-FUNC-003` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Cadastro de maquinario, ajudantes, operadores e entidades operacionais. |
| `REQ-FUNC-004` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Expediente, assistencia offline, checkpoint manual e rastreabilidade de ajudantes. |
| `REQ-FUNC-005` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Agrupamento e criacao multipla. |
| `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-009` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Agendamentos, cronometros, destaque visual e tratamento de cancelamentos. |
| `REQ-FUNC-010` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Modelagem espacial, adjacencias e suporte ao motor de score. |
| `REQ-NFR-001`, `REQ-NFR-003` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Monorepo, stack base, backend e decisoes arquiteturais. |
| `REQ-NFR-002` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | PWA mobile-first em Angular (baseline major 20; validar patch 20.x na implementacao), conectividade e operacao offline; alinhado a DEC-007 e ADR D7 na SPEC. |
| `REQ-NFR-004` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Persistencia relacional e isolamento multi-tenant. |
| `REQ-NFR-005`, `REQ-NFR-006` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | JWT, refresh tokens e rate limiting. |
| `REQ-NFR-007` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md#politica-autenticacao-senha](SPEC/00-visao-arquitetura.md#politica-autenticacao-senha) | Politica de autenticacao segmentada por perfil (D6/DEC-004): Campo (Usuario+PIN) e Administrativo (palavra-passe forte). |
| `REQ-ACE-001`, `REQ-ACE-008` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md) | Isolamento RBAC e auditoria cross-tenant. |
| `REQ-ACE-002`, `REQ-ACE-003`, `REQ-ACE-004`, `REQ-ACE-005`, `REQ-ACE-006` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Aceites ligados a estados, score, alocacao manual, UI e cancelamentos. |
| `REQ-ACE-007` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Seguranca de token; cobertura marcada como alinhada a arquitetura base. |
| `REQ-MET-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Medicao de SLA, atendimento e operacao em campo. |
| `REQ-RISK-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/05-backlog-mvp-glossario.md](SPEC/05-backlog-mvp-glossario.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Riscos de rollout, conectividade e limites do MVP. |

## Resultados da auditoria PRD ↔ SPEC

Resumo agregado de 7 modulos auditados (actualizado em 2026-03-20, pos-Fase 3 — revalidacao global).

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

---

### Auditoria M01 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - ~~`SPEC-M01-001`~~ — **Resolvido (Fase 1.3).** Rastreio `REQ-SCO-003` e texto explicito de cadastro de Maquinario e Ajudante adicionados em `00-visao-arquitetura.md`.
- **Importantes** — Todos resolvidos na Fase 2.
  - ~~`PRD-M01-001`~~ — **Resolvido (Fase 2.6).** Apontadores SPEC adicionados em `REQ-OBJ-003`, `REQ-OBJ-004`, `REQ-SCO-003`, `REQ-SCO-004`.
  - ~~`PRD-M01-002`~~ — **Resolvido (Fase 2.6).** Apontadores SPEC adicionados para Fase 2 e Criterios de Promocao.
  - ~~`SPEC-M01-002`~~ — **Resolvido (Fase 2.3).** Seccao de criterios de promocao adicionada com `REQ-SCO-GAT-001..004`.
  - ~~`SPEC-M01-003`~~ — **Resolvido (Fase 2.3).** `REQ-SCO-F2-005` adicionado a lista de itens adiados.
  - ~~`SPEC-M01-004`~~ — **Resolvido (Fase 2.2).** Checkpoint Manual, localizacao declarada e restricao sem GPS explicitados.
- **Resumo de cobertura**
  - `Coberto`: 21
  - `Parcial`: 2
  - `Nao coberto`: 0

---

### Auditoria M02 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - Nenhum bloqueio PRD↔SPEC identificado no modulo.
- **Importantes** — Todos resolvidos.
  - ~~`PRD-M02-001`~~ — **Resolvido (Fase 2.6).** PRD `REQ-RBAC-005` e `REQ-RBAC-006` agora explicitam leitura de contexto auxiliar para Empreiteiro e Operador na medida necessaria.
  - ~~`SPEC-M02-001`~~ — **Resolvido (Fase 3).** Decisao de design adicionada em `04-rbac-permissoes.md` justificando leitura de contexto para perfis de campo: estritamente funcional, aderente a `REQ-RBAC-005`/`REQ-RBAC-006`, limitada ao tenant.
- **Menores** — Todos resolvidos.
  - ~~`PRD-M02-002`~~ — **Resolvido (Fase 3).** Nota de nomenclatura adicionada em `PRD/01-usuarios-rbac.md` fixando 'Operador de Maquinario' e 'Operador' como sinonimos oficiais.
  - ~~`SPEC-M02-002`~~ — **Resolvido (Fase 3).** Nota de nomenclatura adicionada em `SPEC/04-rbac-permissoes.md` com referencia cruzada ao nome completo do PRD.
- **Resumo de cobertura**
  - `Coberto`: 6
  - `Parcial`: 0
  - `Nao coberto`: 0

---

### Auditoria M03 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - Nenhum bloqueio PRD↔SPEC identificado no modulo.
- **Importantes** — Todos resolvidos.
  - ~~`PRD-M03-001`~~ — **Resolvido (Fase 2.6).** `REQ-JOR-001` agora especifica seleccao de `SetorOperacional` (obrigatorio) e `Quadra`/`Lote` (opcional). *(Subsequentemente actualizado por DEC-005: Quadra/Lote obrigatorios, Local Externo introduzido, SetorOperacional derivado. Revisto por DEC-006: entrega formal de material adiada para pos-MVP; movimentacao de massas tratada como demanda regular com material e destino opcionais.)*
  - ~~`SPEC-M03-001`~~ — **Resolvido (Fase 2.4).** Capacidade #1 (Solicitacao) expandida com captura obrigatoria de localizacao de trabalho.
  - ~~`SPEC-M03-002`~~ — **Resolvido (Fase 2.1).** Passo 3 do motor agora explicita contrato de experiencia da fila: UI nao bloqueante, demandas visiveis e rolaveis.
  - ~~`SPEC-M03-003`~~ — **Resolvido (Fase 1.2, DEC-002).** Encerramento por estouro de SLA no fim do expediente parametrizavel por obra.
- **Resumo de cobertura**
  - `Coberto`: 5
  - `Parcial`: 0
  - `Nao coberto`: 0

---

### Auditoria M04 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - ~~`CROSS-M04-001`~~ — **Resolvido (Fase 1.1, DEC-001).** Modelo hibrido: alocacao manual sobrepoe elegibilidade como excecao auditavel.
- **Importantes** — Todos resolvidos.
  - ~~`PRD-M04-001`~~ — **Resolvido (Fase 2.6).** Apontadores SPEC adicionados para `REQ-FUNC-003..010` em `PRD/03-requisitos-funcionais.md`.
  - ~~`PRD-M04-002`~~ — **Resolvido (Fase 1.1, DEC-001).** Precedencia entre filtro e alocacao manual definida.
  - ~~`SPEC-M04-001`~~ — **Resolvido (Fase 1.1, DEC-001).** Regra Zero documenta DEC-001 explicitamente.
  - ~~`SPEC-M04-002`~~ — **Resolvido (Fase 2.4).** Capacidade #2 (Agrupamento e criacao multipla) adicionada com contrato funcional.
  - ~~`SPEC-M04-003`~~ — **Resolvido (Fase 2.4).** `tempoExecucaoMs` especificado em `02-modelo-dados.md`.
  - ~~`SPEC-M04-004`~~ — **Resolvido (Fase 2.1).** UI nao bloqueante e preservacao das demandas explicitadas.
- **Resumo de cobertura**
  - `Coberto`: 10
  - `Parcial`: 0
  - `Nao coberto`: 0

---

### Auditoria M05 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - ~~`SPEC-M05-002`~~ — **Resolvido (Fase 1.4, DEC-004).** ADR D6 adicionada com politica de autenticacao segmentada por perfil.
- **Importantes** — Todos resolvidos.
  - ~~`SPEC-M05-001`~~ — **Resolvido (Fase 2.2).** ADR de Rate Limiting expandida com endpoints exactos, `HTTP 429`, `Retry-After` e bloqueio de 15 minutos.
  - ~~`SPEC-M05-003`~~ — **Resolvido (Fase 2.5).** Politica de rastreabilidade uniforme adicionada em `06-definicoes-complementares.md` com tabela de entidades e `ResourceAuditLog`.
- **Resumo de cobertura**
  - `Coberto`: 7
  - `Parcial`: 0
  - `Nao coberto`: 0

---

### Auditoria M06 - bloco para `docs/traceability.md`

- **Bloqueantes** — Todos resolvidos.
  - ~~`CROSS-M06-001`~~ — **Resolvido (Fase 1.1, DEC-001).** PRD e SPEC alinhados no modelo hibrido de alocacao.
  - ~~`CROSS-M06-002`~~ — **Resolvido (Fase 1.2, DEC-002).** Auto-encerramento por estouro de SLA no fim do expediente.
- **Importantes** — Todos resolvidos.
  - ~~`PRD-M06-001`~~ — **Resolvido (Fase 2.6).** `REQ-ACE-007` migrado com 3 cenarios Gherkin (expiracao, invalidacao, reuso).
  - ~~`PRD-M06-002`~~ — **Resolvido (Fase 1.1, DEC-001).** `REQ-ACE-003` reescrito com terminologia canonica.
  - ~~`SPEC-M06-001`~~ — **Resolvido (Fase 1.1, DEC-001).** Regra Zero documenta DEC-001.
  - ~~`SPEC-M06-002`~~ — **Resolvido (Fase 2.1).** UI nao bloqueante e demandas visiveis/rolaveis explicitados.
  - ~~`SPEC-M06-003`~~ — **Resolvido (Fase 1.2, DEC-002).** Encerramento por estouro de SLA justificado.
- **Resumo de cobertura**
  - `Coberto`: 8
  - `Parcial`: 0
  - `Nao coberto`: 0

---

### Auditoria M07 - bloco para `docs/traceability.md`

- **Bloqueantes** — Todos resolvidos.
  - ~~`CROSS-M07-001`~~ — **Resolvido (Fase 1.5, DEC-003).** Referencia PRD corrigida para `06-definicoes-complementares.md`.
  - ~~`SPEC-M07-002`~~ — **Resolvido (Fase 1.5, DEC-003).** Contrato analitico canonico adicionado com formula, denominador e janela temporal.
- **Importantes** — Todos resolvidos.
  - ~~`PRD-M07-001`~~ — **Resolvido (Fase 1.5, DEC-003).** Referencia SPEC corrigida.
  - ~~`PRD-M07-002`~~ — **Resolvido (Fase 2.6).** Mitigacao explicita adicionada com responsavel, validacao, auditoria e relatorio.
  - ~~`SPEC-M07-001`~~ — **Resolvido (Fase 2.4).** Seccao de medicao canonica adicionada em `02-modelo-dados.md` com Horas Disponiveis, Horas em Operacao e consulta de referencia.
  - ~~`SPEC-M07-003`~~ — **Resolvido (Fase 2.3).** Seccao de governanca da taxonomia espacial adicionada em `05-backlog-mvp-glossario.md` com 4 regras tecnicas.
- **Resumo de cobertura**
  - `Coberto`: 5
  - `Parcial`: 0
  - `Nao coberto`: 0

---

## Referencias

- [README dos docs](README.md)
- [Indice mestre PRD](PRD/_index.md)
- [Indice mestre SPEC](SPEC/_index.md)
- [JSON global consolidado](audit/output/global/consolidated-global.json)
