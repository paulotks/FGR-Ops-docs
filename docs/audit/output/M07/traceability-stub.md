### Auditoria M07 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `CROSS-M07-001` - `REQ-MET-002` aponta no PRD para `01-modulos-plataforma`, mas a paridade oficial e a matriz global de M07 distribuem metricas e riscos por `02`, `03`, `05` e `06`, deixando sem fonte tecnica canonica o indicador de adocao e engajamento.
  - `SPEC-M07-002` - os SPEC revistos nao definem a fonte do denominador "operadores ativos na folha da quinzena" nem o contrato analitico necessario para verificar `REQ-MET-002`.
- **Importantes**
  - `PRD-M07-001` - `REQ-MET-002` usa no PRD uma referencia cruzada para `01-modulos-plataforma` fora do conjunto de paridade oficial de M07.
  - `PRD-M07-002` - `REQ-RISK-001` identifica o risco de governanca da taxonomia operacional, mas nao explicita a mitigacao esperada apesar do titulo "Riscos e mitigacoes".
  - `SPEC-M07-001` - `02-modelo-dados` nao fecha atributos ou eventos canonicos para calcular `Horas Disponiveis` versus `Horas em Operacao` em `REQ-MET-001`.
  - `SPEC-M07-003` - `05-backlog-mvp-glossario` define a taxonomia espacial, mas nao traduz `REQ-RISK-001` em fluxo tecnico de governanca, validacao ou auditoria cadastral.
- **Resumo de cobertura**
  - `Coberto`: 2
  - `Parcial`: 2
  - `Nao coberto`: 1
