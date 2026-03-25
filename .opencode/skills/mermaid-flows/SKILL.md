---
name: mermaid-flows
description: Gera e mantém diagramas Mermaid em docs/flows/ a partir do PRD, com validação e encadeamento ao workflow de requisitos. Use quando o utilizador pedir fluxo visual, diagrama, mapa de estados, sequência, revisão de fluxo existente, ou quando mudanças em PRD/SPEC implicarem atualizar fluxos documentados.
---

# Mermaid Flows

## Quando usar

Use este skill quando o pedido envolver:
- fluxo visual, diagrama, mapa de estados ou diagrama de sequência
- revisão ou melhoria de um fluxo já em `docs/flows/`
- mudança em PRD/SPEC que impacte um fluxo documentado (atualizar o artefato derivado)

## Fluxo recomendado (orquestração)

1. **Identificar contexto**: módulo(s) PRD/SPEC e `REQ-*` envolvidos — consultar `docs/PRD/_index.md`, `docs/SPEC/_index.md` e, quando útil, `docs/audit/step0-module-mapping.json`.
2. **Ler a fonte**: o PRD (e secções SPEC ligadas) que descreve etapas, decisões, atores e estados; não inventar passos que não estejam sustentados no texto.
3. **Gerar ou atualizar**: escrever ou ajustar blocos `mermaid` no ficheiro adequado em `docs/flows/` (ver convenções abaixo); escolher `flowchart`, `stateDiagram` ou `sequenceDiagram` conforme o caso.
4. **Validar sintaxe**: se o servidor MCP `mcp-mermaid` estiver disponível, validar antes de gravar; caso contrário, confiar no preview Markdown (extensão tipo Markdown Preview Mermaid Support) ou revisão manual cuidadosa.
5. **Apresentar ao utilizador**: resumir o diagrama e pedir revisão explícita quando houver ambiguidade de negócio.
6. **Gaps de requisito**: se o fluxo revelar lacunas, contradições ou necessidade de novos/alterados `REQ-*`, **acionar o skill [docs-audit-consistency](../docs-audit-consistency/SKILL.md)** para alinhar PRD, SPEC, critérios de aceite e rastreabilidade; só depois refletir o resultado no ficheiro de fluxo.
7. **Índice**: ao criar ficheiro novo em `docs/flows/`, atualizar `docs/flows/_index.md` (tabela e convenções já descritas nesse índice).

## Convenções em `docs/flows/`

- Cabeçalho por ficheiro: título; módulos PRD/SPEC relacionados; lista dos `REQ-*` cobertos.
- Um ou mais blocos `mermaid` por ficheiro, quando fizer sentido.
- Rótulos de nós podem citar `REQ-*` para rastreabilidade legível.
- No final do ficheiro, links cruzados para PRD e SPEC, no mesmo padrão de `-> SPEC:` usado em `docs/PRD/` (ex.: `docs/PRD/02-jornada-usuario.md`).

## Regras de sincronização

- Os fluxos são **artefatos derivados** do PRD: não são fonte de verdade isolada.
- Se um fluxo **contradiz** o PRD, resolver o gap em PRD/SPEC (via **docs-audit-consistency**) e **só então** atualizar o Mermaid em `docs/flows/`.
- Manter o cabeçalho de cada ficheiro de fluxo alinhado aos `REQ-*` e links vigentes.

## Integração com **docs-audit-consistency**

- Qualquer alteração de requisito descoberta ou confirmada durante o desenho do fluxo deve seguir o fluxo do skill **docs-audit-consistency** (PRD ↔ SPEC, aceite, `docs/traceability.md`, `docs/audit/decisions-log.md` quando aplicável).
- Após esse skill aplicar mudanças, **reconciliar** o diagrama em `docs/flows/` com o texto atualizado.
- Executar `python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py` quando o trabalho tocar PRD/SPEC/rastreio (ou quando **docs-audit-consistency** tiver sido acionado).

## Integração com o workflow `docs/changes/`

- Se o fluxo implicar **novos** `REQ-*`, **alteração material** ou **remoção** de requisitos, o ciclo documental deve passar por `docs/changes/`:
  1. **Propor**: pasta `docs/changes/<nome-kebab>/` com `proposal.md`, `design.md` e `tasks.md` (ver [docs/changes/README.md](../../../docs/changes/README.md)).
  2. **Aplicar**: tarefas em `tasks.md`; edições sob `docs/`; em seguida **docs-audit-consistency** e o script `check_consistency.py`.
  3. **Arquivar**: quando concluído, mover para `docs/changes/archive/YYYY-MM-DD-<nome>/`.
- Atualizações **puramente ilustrativas** de fluxo que **não** mudam IDs nem texto de requisito podem ir direto a `docs/flows/` sem nova proposta, desde que permaneçam fiéis ao PRD.

## Perguntas quando houver ambiguidade

Antes de fixar ramos ou estados no diagrama, confirmar o mínimo necessário:
- atores e permissões (RBAC) relevantes ao fluxo
- estados terminais e exceções desejadas pelo produto
- se um `REQ-*` referenciado no rótulo ainda é canónico (consultar PRD)

## Saída esperada

Resposta em prosa (sem template rígido), cobrindo:
- que ficheiro(s) em `docs/flows/` foram criados ou alterados
- que `REQ-*` e módulos PRD/SPEC o diagrama cobre
- como foi validada a sintaxe Mermaid (MCP, preview ou revisão)
- se **docs-audit-consistency** ou `docs/changes/` foram acionados e porquê
- pendências, se existirem

## Recursos adicionais

- Auditoria de requisitos: [docs-audit-consistency/SKILL.md](../docs-audit-consistency/SKILL.md)
- Índice e convenções dos fluxos: [docs/flows/_index.md](../../../docs/flows/_index.md)
- Ciclo de mudanças: [docs/changes/README.md](../../../docs/changes/README.md)
