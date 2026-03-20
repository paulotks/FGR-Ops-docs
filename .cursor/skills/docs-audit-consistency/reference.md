# Referencia rapida de consistencia

## Fontes de verdade

- PRD: `docs/PRD/`
- SPEC: `docs/SPEC/`
- Rastreabilidade geral: `docs/traceability.md`
- Auditoria por fase/modulo: `docs/audit/`

## Boas praticas

- Atualizar PRD e SPEC em pares quando houver contrato cruzado.
- Em mudancas de regra de negocio, atualizar tambem:
  - criterios de aceite
  - log de decisoes (`docs/audit/decisions-log.md`), se aplicavel
- Preferir links relativos existentes no repositorio.
- Evitar criacao de novos termos para o mesmo conceito.

## Checklist minimo de revisao

- Existe referencia clara do requisito no modulo correto?
- O texto de aceite esta alinhado com o comportamento descrito?
- Ha referencias quebradas ou caminhos inexistentes?
- O artefato de auditoria ficou consistente com a alteracao?

## Operacoes de requisito

- Inclusao:
  - criar `REQ-*` no modulo PRD correto
  - criar/atualizar contraparte tecnica na SPEC
  - ligar para criterio de aceite, quando aplicavel
- Alteracao:
  - atualizar origem solicitada
  - refletir semanticamente no documento vinculado (PRD ou SPEC)
  - revisar links e anchors afetados
- Exclusao:
  - remover requisito e referencias cruzadas
  - ajustar rastreabilidade para evitar itens orfaos
  - registrar decisao em auditoria quando a remocao for de escopo/regra de produto
