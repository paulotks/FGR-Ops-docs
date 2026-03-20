### Auditoria M03 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - Nenhum bloqueio PRD↔SPEC identificado no modulo.
- **Importantes**
  - `PRD-M03-001` - o PRD nao fixa se a localizacao inicial da demanda usa entidade espacial estruturada do Core, checkpoint manual ou campo livre.
  - `SPEC-M03-001` - `01-modulos-plataforma` cobre a abertura da demanda, mas nao explicita a captura da localizacao de trabalho no momento da requisicao.
  - `SPEC-M03-002` - `03-fila-scoring-estados-sla` cobre prioridade maxima, Regra Zero e empilhamento, mas nao transforma em contrato textual a exigencia de UI sem bloqueio e de fila estrita do operador.
  - `SPEC-M03-003` - `03-fila-scoring-estados-sla` introduz aprovacao automatica de cancelamento apos 24 horas sem justificar essa decisao no contexto do PRD.
- **Resumo de cobertura**
  - `Coberto`: 2
  - `Parcial`: 3
  - `Nao coberto`: 0
