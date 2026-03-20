### Auditoria M06 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - ~~`CROSS-M06-001`~~ _(resolvido por DEC-001)_ - conflito entre cenário de aceite REQ-ACE-003 e Regra Zero eliminado pelo modelo híbrido.
  - `CROSS-M06-002` - `REQ-ACE-006` exige revisao administrativa antes do encerramento definitivo, mas `03-fila-scoring-estados-sla` aprova cancelamentos automaticamente apos 24 horas sem decisao humana.
- **Importantes**
  - `PRD-M06-001` - `REQ-ACE-007` continua apenas como pendente de migracao em `05-criterios-aceite`, sem criterio testavel nem cenario de aceite.
  - ~~`PRD-M06-002`~~ _(resolvido por DEC-001)_ - terminologia canónica `operadorAlocadoId` aplicada em REQ-ACE-003.
  - ~~`SPEC-M06-001`~~ _(resolvido por DEC-001)_ - Regra Zero justifica coexistência com REQ-ACE-003 via modelo híbrido.
  - `SPEC-M06-002` - `03-fila-scoring-estados-sla` destaca prioridade `MAXIMA`, mas nao explicita que as restantes demandas permanecem visiveis e rolaveis na UI mobile de `REQ-ACE-005`.
  - `SPEC-M06-003` - `03-fila-scoring-estados-sla` introduz aprovacao automatica apos 24 horas em `REQ-ACE-006`, adicionando comportamento nao antecipado pelo criterio de aceite.
- **Resumo de cobertura**
  - `Coberto`: 5
  - `Parcial`: 3
  - `Nao coberto`: 0
