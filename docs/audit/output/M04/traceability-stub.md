### Auditoria M04 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - ~~`CROSS-M04-001`~~ _(resolvido por DEC-001)_ - conflito PRD↔SPEC entre filtro estrito e Regra Zero eliminado pelo modelo híbrido.
- **Importantes**
  - `PRD-M04-001` - os apontadores `-> SPEC` do PRD nao refletem toda a cobertura exigida pela matriz do M04, sobretudo em `02-modelo-dados.md` e `06-definicoes-complementares.md`.
  - ~~`PRD-M04-002`~~ _(resolvido por DEC-001)_ - precedência entre filtro logístico e alocação manual documentada no PRD.
  - ~~`SPEC-M04-001`~~ _(resolvido por DEC-001)_ - Regra Zero agora justifica o modelo híbrido com referência a DEC-001.
  - `SPEC-M04-002` - `01-modulos-plataforma` e `02-modelo-dados` nao fecham o contrato funcional de agrupamento/bulk pedido por `REQ-FUNC-005`.
  - `SPEC-M04-003` - `06-definicoes-complementares` nao localiza explicitamente o calculo/persistencia de `tempoExecucaoMs`.
  - `SPEC-M04-004` - `03-fila-scoring-estados-sla` cobre destaque visual de prioridade `MAXIMA`, mas nao explicita UI nao bloqueante nem preservacao das restantes demandas.
- **Resumo de cobertura**
  - `Coberto`: 7
  - `Parcial`: 3
  - `Nao coberto`: 0
