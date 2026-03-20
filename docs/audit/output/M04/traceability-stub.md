### Auditoria M04 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `CROSS-M04-001` - conflito PRD↔SPEC entre o filtro estrito de jurisdicao/compatibilidade (`REQ-FUNC-002`) e a `Regra Zero` de alocacao manual por `operadorAlocadoId` (`REQ-FUNC-006`).
- **Importantes**
  - `PRD-M04-001` - os apontadores `-> SPEC` do PRD nao refletem toda a cobertura exigida pela matriz do M04, sobretudo em `02-modelo-dados.md` e `06-definicoes-complementares.md`.
  - `PRD-M04-002` - o PRD nao fixa a precedencia entre filtro logistico estrito e alocacao manual explicita.
  - `SPEC-M04-001` - `03-fila-scoring-estados-sla` escolhe um bypass manual amplo na `Regra Zero` sem esclarecer se os hard filters continuam obrigatorios.
  - `SPEC-M04-002` - `01-modulos-plataforma` e `02-modelo-dados` nao fecham o contrato funcional de agrupamento/bulk pedido por `REQ-FUNC-005`.
  - `SPEC-M04-003` - `06-definicoes-complementares` nao localiza explicitamente o calculo/persistencia de `tempoExecucaoMs`.
  - `SPEC-M04-004` - `03-fila-scoring-estados-sla` cobre destaque visual de prioridade `MAXIMA`, mas nao explicita UI nao bloqueante nem preservacao das restantes demandas.
- **Resumo de cobertura**
  - `Coberto`: 6
  - `Parcial`: 4
  - `Nao coberto`: 0
