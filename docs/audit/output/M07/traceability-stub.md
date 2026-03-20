### Auditoria M07 - bloco para `docs/traceability.md`

- **Bloqueantes (resolvidos — Fase 1.5, DEC-003)**
  - `CROSS-M07-001` ~~`REQ-MET-002` aponta no PRD para `01-modulos-plataforma`, mas a paridade oficial de M07 distribui metricas por `02`, `03`, `05` e `06`.~~ Resolvido: referencia PRD corrigida para `06-definicoes-complementares.md#contrato-analitico-req-met-002`.
  - `SPEC-M07-002` ~~os SPEC revistos nao definem a fonte do denominador "operadores ativos na folha da quinzena" nem o contrato analitico para `REQ-MET-002`.~~ Resolvido: seccao canonica adicionada em `06-definicoes-complementares.md` com formula, denominador, janela temporal, timezone, criterios de elegibilidade, deduplicacao, integracao RH/folha e artefato de validacao.
- **Importantes (3 em aberto, 1 resolvido)**
  - `PRD-M07-001` ~~`REQ-MET-002` usa referencia cruzada para `01-modulos-plataforma` fora da paridade oficial de M07.~~ Resolvido: referencia corrigida para `06-definicoes-complementares.md#contrato-analitico-req-met-002` (Fase 1.5, DEC-003).
  - `PRD-M07-002` - `REQ-RISK-001` identifica o risco de governanca da taxonomia operacional, mas nao explicita a mitigacao esperada apesar do titulo "Riscos e mitigacoes".
  - `SPEC-M07-001` - `02-modelo-dados` nao fecha atributos ou eventos canonicos para calcular `Horas Disponiveis` versus `Horas em Operacao` em `REQ-MET-001`.
  - `SPEC-M07-003` - `05-backlog-mvp-glossario` define a taxonomia espacial, mas nao traduz `REQ-RISK-001` em fluxo tecnico de governanca, validacao ou auditoria cadastral.
- **Resumo de cobertura**
  - `Coberto`: 3 (era 2)
  - `Parcial`: 2
  - `Nao coberto`: 0 (era 1)
