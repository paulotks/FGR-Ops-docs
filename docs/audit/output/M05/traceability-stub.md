### Auditoria M05 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `SPEC-M05-002` - `00-visao-arquitetura` nao especifica os criterios minimos da politica de palavra-passe de `REQ-NFR-007`, nem o bloqueio de reutilizacao das ultimas 3 credenciais.
- **Importantes**
  - `SPEC-M05-001` - `00-visao-arquitetura` cobre thresholds de rate limiting, mas nao fecha endpoints exatos, `HTTP 429` e bloqueio temporario de 15 minutos exigidos por `REQ-NFR-006`.
  - `SPEC-M05-003` - `02-modelo-dados` cobre isolamento por `obraId` e auditabilidade transacional, mas deixa parcial a rastreabilidade consistente dos recursos operacionais pedida por `REQ-NFR-004`.
- **Resumo de cobertura**
  - `Coberto`: 4
  - `Parcial`: 2
  - `Nao coberto`: 1
