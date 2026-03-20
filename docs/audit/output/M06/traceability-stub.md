### Auditoria M06 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - ~~`CROSS-M06-001`~~ _(resolvido por DEC-001)_ - conflito entre cenário de aceite REQ-ACE-003 e Regra Zero eliminado pelo modelo híbrido.
  - ~~`CROSS-M06-002`~~ _(resolvido por DEC-002)_ - conflito entre REQ-ACE-006 (revisão administrativa) e auto-aprovação na SPEC eliminado: PRD e SPEC alinhados por auto-encerramento por estouro de SLA no fim do expediente parametrizável por obra.
- **Importantes**
  - `PRD-M06-001` - `REQ-ACE-007` continua apenas como pendente de migracao em `05-criterios-aceite`, sem criterio testavel nem cenario de aceite.
  - ~~`PRD-M06-002`~~ _(resolvido por DEC-001)_ - terminologia canónica `operadorAlocadoId` aplicada em REQ-ACE-003.
  - ~~`SPEC-M06-001`~~ _(resolvido por DEC-001)_ - Regra Zero justifica coexistência com REQ-ACE-003 via modelo híbrido.
  - `SPEC-M06-002` - `03-fila-scoring-estados-sla` destaca prioridade `MAXIMA`, mas nao explicita que as restantes demandas permanecem visiveis e rolaveis na UI mobile de `REQ-ACE-005`.
  - ~~`SPEC-M06-003`~~ _(resolvido por DEC-002)_ - auto-encerramento por estouro de SLA no fim do expediente documentado e justificado na SPEC e no PRD com trilha auditável obrigatória.
- **Resumo de cobertura**
  - `Coberto`: 6
  - `Parcial`: 2
  - `Nao coberto`: 0
