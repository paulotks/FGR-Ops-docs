---
name: docs-audit-consistency
description: Orquestra inclusao, alteracao e exclusao de requisitos com atualizacao cruzada entre PRD e SPEC, incluindo criterios de aceite, rastreabilidade e auditoria. Use quando o usuario pedir mudanca em requisito (REQ-*), secao de PRD/SPEC, ou alinhamento de vinculos PRD<->SPEC em docs/.
---

# Docs Audit Consistency

## Quando usar

Use este skill quando o pedido mencionar:
- PRD, SPEC, requisitos funcionais ou nao funcionais
- criterios de aceite
- rastreabilidade (`traceability`, `consolidated`, `module-mapping`)
- auditoria em `docs/audit/`

## Fluxo recomendado

1. Classificar a operacao: `incluir`, `alterar` ou `excluir` requisito.
2. Identificar requisito(s) e modulo(s) afetados em `docs/PRD/` e `docs/SPEC/`.
3. Se faltarem dados para refletir a mudanca na outra ponta (PRD ou SPEC), perguntar antes de editar.
4. Aplicar a mudanca na fonte primaria solicitada pelo usuario.
5. Refletir a mudanca nos artefatos dependentes:
   - referencias cruzadas PRD <-> SPEC
   - criterios de aceite (`docs/PRD/05-criterios-aceite.md`) quando aplicavel
   - rastreabilidade global (`docs/traceability.md`) quando aplicavel
   - log de decisoes (`docs/audit/decisions-log.md`) quando houver decisao de produto
6. Rodar verificacao automatica:
   - `python .opencode/skills/docs-audit-consistency/scripts/check_consistency.py`
7. Se houver inconsistencias, corrigir e rodar novamente.

## Perguntas obrigatorias quando houver ambiguidade

Antes de refletir uma mudanca, confirmar o minimo necessario:
- ID do requisito (`REQ-*`) e tipo (`FUNC`, `NFR`, `ACE`, `RBAC`, etc.)
- escopo da mudanca (texto, regra, estado, SLA, permissao, metrica)
- modulo alvo em PRD e modulo correspondente em SPEC
- necessidade de novo criterio de aceite ou ajuste de criterio existente
- impacto em decisoes de produto (se precisa registrar DEC)

Se o usuario pedir apenas "altera X no PRD", assumir comportamento proativo: mapear impacto em SPEC e perguntar somente o que faltar para executar sem suposicoes arriscadas.

## Mudanca de stack (ex.: frontend)

Quando o pedido alterar framework ou baseline de versao do cliente (ex.: troca de stack web), verificar em sequencia:

1. **PRD** — requisitos NFR afetados (ex.: `REQ-NFR-002`) com texto e IDs estaveis.
2. **SPEC** — visao de arquitetura (`docs/SPEC/00-visao-arquitetura.md`) e ADRs relevantes.
3. **`docs/traceability.md`** — linhas da matriz que cobrem esses REQ com notas semanticamente corretas.
4. **`docs/audit/decisions-log.md`** — novo `DEC-*` com racional, impacto e modulos tocados.
5. Correr `python .opencode/skills/docs-audit-consistency/scripts/check_consistency.py`.

## Regras de sincronizacao PRD <-> SPEC

- Toda mudanca de requisito em PRD deve ter reflexo verificavel na SPEC (link, secao ou regra tecnica).
- Toda mudanca tecnica relevante na SPEC deve manter `Rastreio PRD:` atualizado.
- Em exclusao de requisito, remover ou marcar legado nas referencias cruzadas para evitar links orfaos.
- Manter IDs e terminologia canonica estaveis; evitar renomeacao sem migracao de referencias.

## Regras editoriais

- Escrever em portugues, estilo conciso e orientado a decisao.
- Evitar ficheiros monoliticos como fonte de verdade.
- Manter referencias para os indices modulares (`docs/PRD/_index.md`, `docs/SPEC/_index.md`).
- Usar terminologia consistente dentro do mesmo modulo.

## Saida esperada

Fornecer resposta livre (sem template fixo), cobrindo:
- o que mudou
- porque mudou
- quais verificacoes foram executadas
- pendencias, se existirem

## Recursos adicionais

- Guia rapido: [reference.md](reference.md)
- Script de validacao: [scripts/check_consistency.py](scripts/check_consistency.py)
