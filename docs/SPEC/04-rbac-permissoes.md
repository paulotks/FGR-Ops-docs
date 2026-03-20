# RBAC e permissões

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-003`, `REQ-RBAC-004`, `REQ-RBAC-005`, `REQ-RBAC-006`, `REQ-ACE-001`, `REQ-ACE-008`

Este módulo consolida as regras técnicas de autorização, o isolamento multi-tenant e as matrizes de permissões aplicadas pelo backend.

## Regras transversais de isolamento e bypass

- Toda entidade tenant-scoped opera com `obraId` como escopo obrigatório.
- Perfis `SuperAdmin` e `Board` podem executar bypass de multi-tenancy, ignorando o filtro por `obraId` quando a operação exigir visão transversal.
- O perfil `Board` é estritamente limitado a operações de leitura (`HTTP GET`); qualquer tentativa de `POST`, `PUT`, `PATCH` ou `DELETE` deve falhar com `HTTP 403` antes de atingir o controlador.
- Todo acesso `cross-tenant` executado por `SuperAdmin` ou `Board` deve ser registado em `AuditLogCrossTenant` com, no mínimo, `userId`, `role`, `endpoint`, `obraIdAlvo` (quando inferível) e `timestamp`.

## Perfis de acesso

A herança está suprimida em prol de garantias granulares imutavelmente pré-fornecidas:

> **Nota de nomenclatura:** O perfil `Operador` neste documento corresponde a `Operador de Maquinário` (`REQ-RBAC-006`) no PRD. O nome curto `Operador` é o identificador canónico adoptado pela SPEC.

1. **SuperAdmin**: bypass multi-tenant; visão panóptica do ecossistema.
2. **Board (Diretoria)**: perfil focado na macrogestão (`Role: BOARD`). Bypass multi-tenant passivo via relatórios e dashboards; guard-access aos verbos HTTP restritos prioritariamente a `GET` e analytics/reports.
3. **AdminOperacional**: administra uma ou N obras. Capaz de realizar alocações manuais em `CreateDemandaDto` e lote `CreateMultipleDemandasDto`.
4. **UsuarioInternoFGR**: visualiza relatórios, gere contestações na máquina de estados dentro do seu tenant e pode escolher operadores manualmente na criação de demanda.
5. **Empreiteiro**: enclausurado nas demandas da sua autoria.
6. **Operador** (sinónimo: Operador de Maquinário): PWA em campo via expediente focado, ordenação fluida e sem travas de interface cega ("blindagem"). Vê apenas a fila do motor preordenada dinamicamente.

## Matriz completa de permissões por recurso (Lacuna 1)

O sistema verifica acessos via Guards NestJS avaliando a chave da permissão. O formato adotado é `<módulo>:<recurso>:<ação>`.
Os perfis assinalados com `cross` têm autorização de atuar ignorando restrições de tenant (`obraId`). Onde não há natureza da ação para o recurso, usa-se `—`.

| Permissão | SuperAdmin | Board | AdminOperacional | UsuarioInternoFGR | Empreiteiro | Operador |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `core:usuario:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:usuario:read` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `core:usuario:update` | ✓ | ✗ | ✓*[1] | ✗ | ✗ | ✗ |
| `core:usuario:delete` | ✓ | ✗ | ✓*[1] | ✗ | ✗ | ✗ |
| `core:usuario:cancel` | — | — | — | — | — | — |
| `core:usuario:cancel-request` | — | — | — | — | — | — |
| `core:usuario:approve` | — | — | — | — | — | — |
| `core:usuario:reject` | — | — | — | — | — | — |
| `core:usuario:allocate` | — | — | — | — | — | — |
| `core:usuario:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `core:obra:create` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `core:obra:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `core:obra:update` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `core:obra:delete` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `core:obra:cancel` | — | — | — | — | — | — |
| `core:obra:cancel-request` | — | — | — | — | — | — |
| `core:obra:approve` | — | — | — | — | — | — |
| `core:obra:reject` | — | — | — | — | — | — |
| `core:obra:allocate` | — | — | — | — | — | — |
| `core:obra:export` | cross | cross | ✓ | ✗ | ✗ | ✗ |
| `core:setor-operacional:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:setor-operacional:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `core:setor-operacional:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:setor-operacional:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:setor-operacional:cancel` | — | — | — | — | — | — |
| `core:setor-operacional:cancel-request` | — | — | — | — | — | — |
| `core:setor-operacional:approve` | — | — | — | — | — | — |
| `core:setor-operacional:reject` | — | — | — | — | — | — |
| `core:setor-operacional:allocate` | — | — | — | — | — | — |
| `core:setor-operacional:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `core:quadra:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:quadra:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `core:quadra:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:quadra:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:quadra:cancel` | — | — | — | — | — | — |
| `core:quadra:cancel-request` | — | — | — | — | — | — |
| `core:quadra:approve` | — | — | — | — | — | — |
| `core:quadra:reject` | — | — | — | — | — | — |
| `core:quadra:allocate` | — | — | — | — | — | — |
| `core:quadra:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `core:lote:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:lote:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `core:lote:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:lote:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:lote:cancel` | — | — | — | — | — | — |
| `core:lote:cancel-request` | — | — | — | — | — | — |
| `core:lote:approve` | — | — | — | — | — | — |
| `core:lote:reject` | — | — | — | — | — | — |
| `core:lote:allocate` | — | — | — | — | — | — |
| `core:lote:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `core:rua:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:rua:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `core:rua:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:rua:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:rua:cancel` | — | — | — | — | — | — |
| `core:rua:cancel-request` | — | — | — | — | — | — |
| `core:rua:approve` | — | — | — | — | — | — |
| `core:rua:reject` | — | — | — | — | — | — |
| `core:rua:allocate` | — | — | — | — | — | — |
| `core:rua:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `core:lote-adjacencia:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:lote-adjacencia:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `core:lote-adjacencia:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:lote-adjacencia:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `core:lote-adjacencia:cancel` | — | — | — | — | — | — |
| `core:lote-adjacencia:cancel-request` | — | — | — | — | — | — |
| `core:lote-adjacencia:approve` | — | — | — | — | — | — |
| `core:lote-adjacencia:reject` | — | — | — | — | — | — |
| `core:lote-adjacencia:allocate` | — | — | — | — | — | — |
| `core:lote-adjacencia:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:demanda:create` | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ |
| `machinery:demanda:read` | cross | cross | ✓ | ✓ | ✓*[2] | ✓*[3] |
| `machinery:demanda:update` | ✓ | ✗ | ✓ | ✓ | ✓*[4] | ✗ |
| `machinery:demanda:delete` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `machinery:demanda:cancel` | ✓ | ✗ | ✓ | ✓ | ✓*[4] | ✗ |
| `machinery:demanda:cancel-request` | ✗ | ✗ | ✗ | ✗ | ✗ | ✓*[5] |
| `machinery:demanda:approve` | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| `machinery:demanda:reject` | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| `machinery:demanda:allocate` | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| `machinery:demanda:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:demanda-grupo:create` | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ |
| `machinery:demanda-grupo:read` | cross | cross | ✓ | ✓ | ✓*[2] | ✗ |
| `machinery:demanda-grupo:update` | ✓ | ✗ | ✓ | ✓ | ✓*[4] | ✗ |
| `machinery:demanda-grupo:delete` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `machinery:demanda-grupo:cancel` | ✓ | ✗ | ✓ | ✓ | ✓*[4] | ✗ |
| `machinery:demanda-grupo:cancel-request` | — | — | — | — | — | — |
| `machinery:demanda-grupo:approve` | — | — | — | — | — | — |
| `machinery:demanda-grupo:reject` | — | — | — | — | — | — |
| `machinery:demanda-grupo:allocate` | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| `machinery:demanda-grupo:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:expediente:create` | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ |
| `machinery:expediente:read` | cross | cross | ✓ | ✓ | ✗ | ✓*[3] |
| `machinery:expediente:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✓*[3] |
| `machinery:expediente:delete` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `machinery:expediente:cancel` | — | — | — | — | — | — |
| `machinery:expediente:cancel-request` | — | — | — | — | — | — |
| `machinery:expediente:approve` | — | — | — | — | — | — |
| `machinery:expediente:reject` | — | — | — | — | — | — |
| `machinery:expediente:allocate` | — | — | — | — | — | — |
| `machinery:expediente:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:maquinario:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:maquinario:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `machinery:maquinario:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:maquinario:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:maquinario:cancel` | — | — | — | — | — | — |
| `machinery:maquinario:cancel-request` | — | — | — | — | — | — |
| `machinery:maquinario:approve` | — | — | — | — | — | — |
| `machinery:maquinario:reject` | — | — | — | — | — | — |
| `machinery:maquinario:allocate` | — | — | — | — | — | — |
| `machinery:maquinario:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:ajudante:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:ajudante:read` | cross | cross | ✓ | ✓ | ✗ | ✓ |
| `machinery:ajudante:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:ajudante:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:ajudante:cancel` | — | — | — | — | — | — |
| `machinery:ajudante:cancel-request` | — | — | — | — | — | — |
| `machinery:ajudante:approve` | — | — | — | — | — | — |
| `machinery:ajudante:reject` | — | — | — | — | — | — |
| `machinery:ajudante:allocate` | — | — | — | — | — | — |
| `machinery:ajudante:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:operador:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:operador:read` | cross | cross | ✓ | ✓ | ✗ | ✓*[6] |
| `machinery:operador:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:operador:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:operador:cancel` | — | — | — | — | — | — |
| `machinery:operador:cancel-request` | — | — | — | — | — | — |
| `machinery:operador:approve` | — | — | — | — | — | — |
| `machinery:operador:reject` | — | — | — | — | — | — |
| `machinery:operador:allocate` | — | — | — | — | — | — |
| `machinery:operador:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:empreiteira:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:empreiteira:read` | cross | cross | ✓ | ✓ | ✓*[2] | ✗ |
| `machinery:empreiteira:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:empreiteira:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:empreiteira:cancel` | — | — | — | — | — | — |
| `machinery:empreiteira:cancel-request` | — | — | — | — | — | — |
| `machinery:empreiteira:approve` | — | — | — | — | — | — |
| `machinery:empreiteira:reject` | — | — | — | — | — | — |
| `machinery:empreiteira:allocate` | — | — | — | — | — | — |
| `machinery:empreiteira:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:servico:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:servico:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `machinery:servico:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:servico:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:servico:cancel` | — | — | — | — | — | — |
| `machinery:servico:cancel-request` | — | — | — | — | — | — |
| `machinery:servico:approve` | — | — | — | — | — | — |
| `machinery:servico:reject` | — | — | — | — | — | — |
| `machinery:servico:allocate` | — | — | — | — | — | — |
| `machinery:servico:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:material:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:material:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `machinery:material:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:material:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:material:cancel` | — | — | — | — | — | — |
| `machinery:material:cancel-request` | — | — | — | — | — | — |
| `machinery:material:approve` | — | — | — | — | — | — |
| `machinery:material:reject` | — | — | — | — | — | — |
| `machinery:material:allocate` | — | — | — | — | — | — |
| `machinery:material:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:relatorio:create` | — | — | — | — | — | — |
| `machinery:relatorio:read` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:relatorio:update` | — | — | — | — | — | — |
| `machinery:relatorio:delete` | — | — | — | — | — | — |
| `machinery:relatorio:cancel` | — | — | — | — | — | — |
| `machinery:relatorio:cancel-request` | — | — | — | — | — | — |
| `machinery:relatorio:approve` | — | — | — | — | — | — |
| `machinery:relatorio:reject` | — | — | — | — | — | — |
| `machinery:relatorio:allocate` | — | — | — | — | — | — |
| `machinery:relatorio:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:solicitacao-cancelamento:create` | — | — | — | — | — | — |
| `machinery:solicitacao-cancelamento:read` | cross | cross | ✓ | ✓ | ✗ | ✓*[5] |
| `machinery:solicitacao-cancelamento:update` | — | — | — | — | — | — |
| `machinery:solicitacao-cancelamento:delete` | — | — | — | — | — | — |
| `machinery:solicitacao-cancelamento:cancel` | — | — | — | — | — | — |
| `machinery:solicitacao-cancelamento:cancel-request` | — | — | — | — | — | — |
| `machinery:solicitacao-cancelamento:approve` | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| `machinery:solicitacao-cancelamento:reject` | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| `machinery:solicitacao-cancelamento:allocate` | — | — | — | — | — | — |
| `machinery:solicitacao-cancelamento:export` | — | — | — | — | — | — |

[1] Apenas sobre utilizadores pertencentes à mesma obra e com perfil hierárquico inferior ou igual.
[2] Permitido estritamente para leitura de registos da sua autoria ou inerentes ao seu cadastro/entidade.
[3] Permitido apenas se o operador autenticado estiver a agir sobre o seu próprio expediente ou sobre demandas visíveis ativamente alocadas na fila.
[4] Permitido ao `Empreiteiro` apenas se a demanda for da sua autoria e estritamente enquanto estiver no estado inicial `PENDENTE`.
[5] Permitido estritamente sobre a demanda pela qual está alocado em `EM_ANDAMENTO` ou sobre a qual emitiu uma solicitação de cancelamento em `PENDENTE_APROVACAO`.
[6] Permitido apenas para consultar relatórios formatados ou metadados do seu próprio vínculo.

## Matriz de permissões condicionadas ao estado da demanda (Lacuna 2)

A tabela abaixo exibe exaustivamente o cruzamento do recurso `demanda` por `EstadoAtual`, `Ação` requerida e perfis autorizados. Qualquer tentativa de transição ou ação restrita não abordada aqui denota rejeição pelo Guard na infraestrutura NestJS.

| Estado | Ação | Perfis autorizados | Condição adicional |
| :--- | :--- | :--- | :--- |
| `[*]` (nulo) | `create` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` | Cria e transita o fluxo em `PENDENTE`. Caso o payload possua `dataAgendada` e seja emitido por admin, cai em `AGENDADA`. |
| `AGENDADA` | `update` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Permite correções do agendamento, do horário cravado ou realocações manuais. |
| `AGENDADA` | `cancel` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Cancela diretamente a demanda ainda dormente e futura da esteira. |
| `AGENDADA` | `allocate` / `antecipar` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Bypass manual coercivo injetando preemptivamente o agendamento em `PENDENTE` em tempo real. |
| `[*]` | `read` / `export` | `SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro`, `Operador` | Visualização geral ou condicional ao perfil; `Operador` e `Empreiteiro` restritos à própria posse. |
| `PENDENTE` | `update` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` | Administradores podem corrigir alocações etc.; `Empreiteiro` pode alterar ordens exclusivamente criadas por si. |
| `PENDENTE` | `cancel` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` | Transita para `CANCELADA`. Justificativa sempre guardada no log. |
| `PENDENTE` | `allocate` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Bypass manual coercivo (Regra Zero), injetando `operadorAlocadoId`. |
| `PENDENTE` | `iniciar` | `Operador` | Permite engajamento estritamente ao operador que recebeu a demanda como topo da fila ou por alocação explícita. |
| `EM_ANDAMENTO` | `update` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Útil para corrigir metadados sem devolver o serviço em execução. |
| `EM_ANDAMENTO` | `concluir` | `Operador` | Transita terminalmente para `CONCLUIDA`; restrito ao operador atualmente vinculado. |
| `EM_ANDAMENTO` | `cancel-request` | `Operador` | Invoca a transição `solicitar_cancelamento` para `PENDENTE_APROVACAO`. |
| `EM_ANDAMENTO` | `devolver` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Força administrativa que aliena o operador da execução e reinjeta a demanda após `RETORNADA`. |
| `PENDENTE_APROVACAO` | `approve` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Acata a solicitação de cancelamento e transita definitivamente para `CANCELADA`. |
| `PENDENTE_APROVACAO` | `reject` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Rejeita formalmente o pedido do operador e devolve o fluxo a `EM_ANDAMENTO`. |
| `CONCLUIDA` | mutação | nenhum | Demanda terminal concluída para uso contábil e de medição; ações reescreventes, operacionais e destrutivas perdem validade. |
| `CANCELADA` | mutação | nenhum | Demanda finalizada como supressa; impede modificações subsequentes. |

## Decisões de design

> Decisão: Agrupamos os domínios hierárquicos e recursos territoriais (`lote-adjacencia`, `rua`, `quadra`, `lote` e `setor-operacional`) espelhando as mesmas restrições exatas do cadastro base (apenas `AdminOperacional` e `SuperAdmin` criam/alteram), visto que mapeiam imutáveis da obra.
>
> Decisão: A ação `export` foi liberada para gestores de obra e diretoria, mas proibida para `Empreiteiro` e `Operador` por escopo concorrencial e finalidade puramente operacional.
>
> Decisão: O recurso `solicitacao-cancelamento` foi blindado para manter design coeso de REST API de cancel-requests independentes por ID, exposto sob os verbos `approve` e `reject`, afetando inerentemente o aggregate root `Demanda`.
>
> Decisão: A matriz explicita ações inativas/inexistentes com `—` para anular inferências indevidas no momento de instanciar metadados de Guards e decorators.
>
> Decisão (leitura de contexto para perfis de campo): `Empreiteiro` e `Operador` possuem permissão de leitura (`read`) em recursos de contexto como `core:obra`, `core:setor-operacional`, `core:quadra`, `core:lote`, `core:rua`, `machinery:maquinario`, `machinery:servico` e `machinery:material`. Essa abertura é estritamente funcional e aderente ao escopo restrito definido no PRD (`REQ-RBAC-005` e `REQ-RBAC-006`): o `Empreiteiro` necessita consultar obra, hierarquia territorial e catálogos para preencher o formulário de abertura de demanda; o `Operador` necessita consultar obra, setor operacional, quadra, lote, maquinário e serviços para visualizar a fila operacional e executar demandas. Todas estas leituras são limitadas ao tenant da obra atribuída — não há bypass cross-tenant — e servem exclusivamente como contexto auxiliar de preenchimento ou visualização, sem conceder capacidade de mutação, exportação ou acesso a dados de outros perfis.
