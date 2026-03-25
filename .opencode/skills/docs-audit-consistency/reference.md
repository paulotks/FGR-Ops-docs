# Referencia rapida de consistencia

## Fontes de verdade

- PRD: `docs/PRD/`
- SPEC: `docs/SPEC/`
- Rastreabilidade geral: `docs/traceability.md`
- Auditoria por fase/modulo: `docs/audit/`

## Artefatos derivados

- Fluxos visuais (diagramas Mermaid): `docs/flows/`
  - Derivados do PRD; nao sao fonte de verdade isolada. Se o fluxo contradizer o PRD, corrigir primeiro PRD/SPEC e depois o ficheiro em `docs/flows/`.
  - Ao incluir, alterar ou remover REQ-* (especialmente jornadas e estados), rever os fluxos que referenciam esses requisitos e atualiza-los quando o comportamento documentado mudar.
  - Manutencao orientada pela skill `.cursor/skills/mermaid-flows/SKILL.md` quando a alteracao for apenas visual; mudancas de requisito continuam a seguir este workflow (PRD, SPEC, rastreabilidade).

## Boas praticas

- Atualizar PRD e SPEC em pares quando houver contrato cruzado.
- Em mudancas de regra de negocio, atualizar tambem:
  - criterios de aceite
  - log de decisoes (`docs/audit/decisions-log.md`), se aplicavel
  - fluxos em `docs/flows/` quando REQ-* ou jornadas afetados tiverem diagramas correspondentes
- Preferir links relativos existentes no repositorio.
- Evitar criacao de novos termos para o mesmo conceito.

## Checklist minimo de revisao

- Existe referencia clara do requisito no modulo correto?
- O texto de aceite esta alinhado com o comportamento descrito?
- Ha referencias quebradas ou caminhos inexistentes?
- O artefato de auditoria ficou consistente com a alteracao?
- Os ficheiros em `docs/flows/` que citam REQ-* alterados continuam alinhados ao PRD?

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
