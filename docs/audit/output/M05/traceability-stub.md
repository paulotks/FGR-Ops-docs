### Auditoria M05 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - ~~`SPEC-M05-002`~~ — **Resolvido (Fase 1.4, DEC-004).** ADR D6 adicionada em `00-visao-arquitetura.md` com politica de autenticacao segmentada por perfil: Campo (Usuario+PIN com controlos compensatorios) e Administrativo (palavra-passe forte conforme `REQ-NFR-007`). PRD `REQ-NFR-007` actualizado para reflectir segmentacao. `REQ-NFR-007` passa de `Nao coberto` para `Coberto`.
- **Importantes**
  - `SPEC-M05-001` - `00-visao-arquitetura` cobre thresholds de rate limiting, mas nao fecha endpoints exatos, `HTTP 429` e bloqueio temporario de 15 minutos exigidos por `REQ-NFR-006`.
  - `SPEC-M05-003` - `02-modelo-dados` cobre isolamento por `obraId` e auditabilidade transacional, mas deixa parcial a rastreabilidade consistente dos recursos operacionais pedida por `REQ-NFR-004`.
- **Resumo de cobertura**
  - `Coberto`: 5 (era 4)
  - `Parcial`: 2
  - `Nao coberto`: 0 (era 1)
