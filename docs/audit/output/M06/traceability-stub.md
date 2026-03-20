### Auditoria M06 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `CROSS-M06-001` - `REQ-ACE-003` diverge entre o cenario do PRD, que faz a jurisdicao/logistica superar a preferencia manual, e a SPEC, que preserva a `Regra Zero` para `operadorAlocadoId`.
  - `CROSS-M06-002` - `REQ-ACE-006` exige revisao administrativa antes do encerramento definitivo, mas `03-fila-scoring-estados-sla` aprova cancelamentos automaticamente apos 24 horas sem decisao humana.
- **Importantes**
  - `PRD-M06-001` - `REQ-ACE-007` continua apenas como pendente de migracao em `05-criterios-aceite`, sem criterio testavel nem cenario de aceite.
  - `PRD-M06-002` - o PRD usa "preferencia manual de operador" em `REQ-ACE-003` sem ligar explicitamente o termo a `operadorAlocadoId` ou a outro mecanismo tecnico.
  - `SPEC-M06-001` - `03-fila-scoring-estados-sla` resolve `REQ-ACE-003` a favor do bypass manual sem justificar a convivencia com o cenario de aceite.
  - `SPEC-M06-002` - `03-fila-scoring-estados-sla` destaca prioridade `MAXIMA`, mas nao explicita que as restantes demandas permanecem visiveis e rolaveis na UI mobile de `REQ-ACE-005`.
  - `SPEC-M06-003` - `03-fila-scoring-estados-sla` introduz aprovacao automatica apos 24 horas em `REQ-ACE-006`, adicionando comportamento nao antecipado pelo criterio de aceite.
- **Resumo de cobertura**
  - `Coberto`: 4
  - `Parcial`: 4
  - `Nao coberto`: 0
