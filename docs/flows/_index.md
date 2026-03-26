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
| [01-movimentacao-concreto-lote-adjacente.md](01-movimentacao-concreto-lote-adjacente.md) | Empreiteiro: PIN, origem/destino Quadra+Lote (ex. Q04 L02→L03), Munck/concreto; motor atualiza fila. | REQ-JOR-001…004 | [02-jornada-usuario.md](../PRD/02-jornada-usuario.md) |
| [02-execucao-campo-operador.md](02-execucao-campo-operador.md) | Operador: check-in → demanda ativa → pausar/concluir → solicitação de cancelamento. | REQ-JOR-004, REQ-FUNC-006…008, REQ-ACE-004…005 | [02-jornada-usuario.md](../PRD/02-jornada-usuario.md) |
| [03-fila-score-triagem.md](03-fila-score-triagem.md) | Pipeline de distribuição: Regra Zero → Hard Filter → Destaque → Score → Ordenação. | REQ-JOR-002…003, REQ-FUNC-001…002, REQ-ACE-002…003 | [03-requisitos-funcionais.md](../PRD/03-requisitos-funcionais.md) |
| [04-cancelamento-sla.md](04-cancelamento-sla.md) | SLA timeout → PENDENTE_APROVACAO → encerramento automático no fim do expediente → revisão pós-facto. | REQ-JOR-005, REQ-FUNC-008…009, REQ-ACE-006 | [05-criterios-aceite.md](../PRD/05-criterios-aceite.md) |
| [05-autenticacao-rbac.md](05-autenticacao-rbac.md) | Login segmentado (PIN campo / senha admin), JWT, isolamento multi-tenant e bypass cross-tenant. | REQ-RBAC-001…006, REQ-NFR-005…007, REQ-ACE-001, REQ-ACE-008 | [01-usuarios-rbac.md](../PRD/01-usuarios-rbac.md) |

- [Índice PRD](../PRD/_index.md)
- [Matriz de rastreabilidade](../traceability.md)

[Voltar ao README dos docs](../README.md)
