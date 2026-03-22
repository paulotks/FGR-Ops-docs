# Índice — fluxos visuais (Mermaid)

Artefatos derivados do PRD: diagramas em Mermaid para revisão rápida de jornadas, estados e sequências. A **fonte de verdade** permanece em `docs/PRD/`; se um fluxo divergir do PRD, corrigir primeiro o PRD/SPEC (workflow de auditoria) e depois atualizar o ficheiro em `docs/flows/`.

## Convenções

| Regra | Descrição |
| ----- | --------- |
| Cabeçalho | Cada ficheiro inclui título, PRD/SPEC relacionados e lista de `REQ-*` cobertos. |
| Diagramas | Um ou mais blocos `mermaid` (`flowchart`, `stateDiagram`, `sequenceDiagram`, conforme o caso). |
| Rótulos | Nos nós, referenciar `REQ-*` quando ajudar a rastreabilidade. |
| Links | No final do ficheiro, links cruzados para PRD e SPEC (padrão `-> SPEC:` como em `docs/PRD/`). |
| Novos ficheiros | Ao adicionar fluxo novo, incluir uma linha na tabela abaixo. |

## Ficheiros

| Arquivo | Resumo | REQ-* principais | PRD |
| ------- | ------ | ---------------- | --- |
| [00-jornada-principal.md](00-jornada-principal.md) | Fluxo operacional Machinery Link: pedido → triagem → score → execução → auditoria. | REQ-JOR-001…005 | [02-jornada-usuario.md](../PRD/02-jornada-usuario.md) |
| [01-movimentacao-concreto-lote-adjacente.md](01-movimentacao-concreto-lote-adjacente.md) | Empreiteiro: PIN, origem/destino Quadra+Lote (ex. Q01 L04→L05), Munck/concreto; motor atualiza fila. | REQ-JOR-001…004 | [02-jornada-usuario.md](../PRD/02-jornada-usuario.md) |

- [Índice PRD](../PRD/_index.md)
- [Matriz de rastreabilidade](../traceability.md)

[Voltar ao README dos docs](../README.md)
