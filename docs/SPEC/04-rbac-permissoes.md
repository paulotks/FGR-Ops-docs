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

> **Nota de nomenclatura:** O perfil `Operador` neste documento corresponde a `Operador de Maquinário` (`REQ-RBAC-006`) no PRD. O nome curto `Operador` é o identificador canônico adotado pela SPEC.

1. **SuperAdmin**: bypass multi-tenant; visão panóptica do ecossistema.
2. **Board (Diretoria)**: perfil focado na macrogestão (`Role: BOARD`). Bypass multi-tenant passivo via relatórios e dashboards; guard-access aos verbos HTTP restritos prioritariamente a `GET` e analytics/reports.
3. **AdminOperacional**: administra uma ou N obras. Capaz de realizar alocações manuais em `CreateDemandaDto` e lote `CreateMultipleDemandasDto`.
4. **UsuarioInternoFGR** (Gerentes, Engenheiros, Encarregados de Obra): acesso ao painel web completo do módulo Machinery-Link para visibilidade gerencial (leitura total); acesso ao aplicativo mobile para criação de demandas simples (view equivalente ao `Empreiteiro`, sem pré-seleção de operador). Não pode cancelar, redistribuir ou realocar demandas, criar agendamentos, nem gerir cadastros operacionais. (DEC-020)
5. **Empreiteiro**: enclausurado nas demandas da sua autoria.
6. **Operador** (sinônimo: Operador de Maquinário): PWA em campo via expediente focado, ordenação fluida e sem travas de interface cega ("blindagem"). Vê apenas a fila do motor preordenada dinamicamente.
7. **TOWER_OPERATOR** (Operador de Torre, Slice 1): perfil de leitura introduzido no enum `Perfil` (`packages/types`). Permissões iniciais conservadoras — apenas leitura de catálogos e contexto de obra, nenhuma escrita, tenant-scoped sem bypass. Detalhe na subseção "Perfil TOWER_OPERATOR" abaixo. (DEC-039)

### Habilitação do Operador — tipo (competência) + máquina (unidade) (ADR 0004)

A habilitação do `Operador` para operar maquinário tem **dois níveis independentes, em cascata estrita**:

1. **Tipo (`OperadorTipoMaquinario`)** — competência/habilitação por `TipoMaquinario`; alimenta o hard-filter de compatibilidade do motor de fila (auto-allocator). Gerido via `POST/PATCH /operadores` (`tiposMaquinarioIds`).
2. **Máquina (`OperadorMaquinario`)** — unidade específica liberada para o **check-in**; **exige** que o tipo da máquina esteja entre os tipos habilitados do mesmo operador (cascata, validada no write, não por constraint declarativa). Gerido via `POST/PATCH /operadores` (`maquinariosIds`, replace-whole-set combinado com `tiposMaquinarioIds` na mesma transação — ADR 0004).

Tipo sozinho **nunca** libera check-in — motivo: maquinários são frequentemente alugados, e dois operadores habilitados ao mesmo tipo podem ter permissão para unidades diferentes. `IniciarExpedienteUseCase` (`POST /expediente/checkin`) valida que a máquina informada está liberada para o operador (linha em `OperadorMaquinario`) **após** a checagem de existência da máquina no tenant (`404 TEN-001`) e **antes** da checagem de expediente duplicado (`409 OPR-003`); falha ⇒ `403 OPR-011`. Este é o **primeiro** portão de elegibilidade instalado no check-in (antes inexistente). O motor de fila (allocator) **continua** filtrando só por tipo (`OperadorTipoMaquinario`) — a integração alocador↔máquina liberada fica **fora do MVP-15jul** (parqueada, ADR 0004).

## Matriz completa de permissões por recurso

> *Esta seção resolveu a Lacuna 1 identificada em audit 2026-03-26.*

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
| `core:obra:configuracoes` [9] | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
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
| `machinery:demanda:create` *[8] | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ |
| `machinery:demanda:read` | cross | cross | ✓ | ✓ | ✓*[2] | ✓*[3] |
| `machinery:demanda:update` | ✓ | ✗ | ✓ | ✓ | ✓*[4] | ✗ |
| `machinery:demanda:delete` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `machinery:demanda:cancel` | ✓ | ✗ | ✓ | ✗ | ✓*[4] | ✓*[6] |
| `machinery:demanda:cancel-request` | — | — | — | — | — | ✓*[7] |
| `machinery:demanda:approve` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:demanda:reject` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:demanda:allocate` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:demanda:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:demanda-grupo:create` | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ |
| `machinery:demanda-grupo:read` | cross | cross | ✓ | ✓ | ✓*[2] | ✗ |
| `machinery:demanda-grupo:update` | ✓ | ✗ | ✓ | ✓ | ✓*[4] | ✗ |
| `machinery:demanda-grupo:delete` | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `machinery:demanda-grupo:cancel` | ✓ | ✗ | ✓ | ✗ | ✓*[4] | ✗ |
| `machinery:demanda-grupo:cancel-request` | — | — | — | — | — | — |
| `machinery:demanda-grupo:approve` | — | — | — | — | — | — |
| `machinery:demanda-grupo:reject` | — | — | — | — | — | — |
| `machinery:demanda-grupo:allocate` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
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
| `machinery:tipo-maquinario:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:tipo-maquinario:read` | cross | cross | ✓ | ✓ | ✓ | ✓ |
| `machinery:tipo-maquinario:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:tipo-maquinario:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:tipo-maquinario:cancel` | — | — | — | — | — | — |
| `machinery:tipo-maquinario:cancel-request` | — | — | — | — | — | — |
| `machinery:tipo-maquinario:approve` | — | — | — | — | — | — |
| `machinery:tipo-maquinario:reject` | — | — | — | — | — | — |
| `machinery:tipo-maquinario:allocate` | — | — | — | — | — | — |
| `machinery:tipo-maquinario:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
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
| `machinery:operador:read` | cross | cross | ✓ | ✓ | ✗ | ✓*[5] |
| `machinery:operador:update` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:operador:delete` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:operador:cancel` | — | — | — | — | — | — |
| `machinery:operador:cancel-request` | — | — | — | — | — | — |
| `machinery:operador:approve` | — | — | — | — | — | — |
| `machinery:operador:reject` | — | — | — | — | — | — |
| `machinery:operador:allocate` | — | — | — | — | — | — |
| `machinery:operador:export` | cross | cross | ✓ | ✓ | ✗ | ✗ |
| `machinery:operador-setor:update` *[12] | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:empreiteira:create` | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| `machinery:empreiteira:read` | cross | cross | ✓ | ✓ | ✗ [10] | ✗ |
| `machinery:prontidao:read` [11] | cross | cross | ✓ | ✗ | ✗ | ✗ |
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
<!-- machinery:solicitacao-cancelamento:* — recurso (entidade separada) removido do MVP por DEC-019 (2026-04-13). DEC-029 (2026-04-20) reintroduz o fluxo de solicitação de cancelamento diretamente via machinery:demanda:cancel-request, restrito a demandas agendadas. -->


### Perfil TOWER_OPERATOR (DEC-039)

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-RBAC-006`, `REQ-FUNC-003`

O perfil `TOWER_OPERATOR` não possui coluna dedicada na matriz acima: suas permissões da Slice 1 são deliberadamente conservadoras e o conjunto exato de leituras de Demanda/Fila será refinado quando a tela da torre sair de placeholder — a coluna dedicada será adicionada nesse refinamento (DEC-039). Até lá, valem as seguintes linhas:

- **Leitura (`read`) — equivalente ao `Operador`** nos catálogos globais e recursos de contexto de obra: `machinery:tipo-maquinario:read` (`GET /tipos-maquinario`), `core:obra:read`, `core:setor-operacional:read`, `core:quadra:read`, `core:lote:read`, `core:rua:read`, `machinery:maquinario:read`, `machinery:servico:read`, `machinery:material:read`; e leitura da fila da obra (`GET /obras/:id/fila`).
- **Escrita — exceção única `machinery:demanda:create` (carve-out MVP-15jul — DEC-040, amenda DEC-039):** o `TOWER_OPERATOR` **pode criar Demanda** via `POST /demandas` (estado inicial `PENDENTE`, contrato free-text do MVP) — ele é o operador humano que orquestra a fila no escopo reduzido (substitui o scoring algorítmico). Nenhuma outra escrita: `update`/`delete`/`export` → ✗ em todos os recursos; as escritas de catálogo (`POST`/`PATCH`/`DELETE /tipos-maquinario` e demais) permanecem restritas a `AdminOperacional` + `SuperAdmin`.
- **Leitura de prontidão da obra (`machinery:prontidao:read`, DEC-046 — alargado DEC-052):** `TOWER_OPERATOR` lê `GET /obras/:obraId/prontidao` (`PRONTIDAO_READ_PERFIS`) e vê o banner de prontidão no dashboard de gestão — mesma obra, sem bypass. Antes de DEC-052 o perfil era excluído (só `SuperAdmin`/`Board`/`AdminOperacional`); Paulo confirmou (2026-07-17) que o `TOWER_OPERATOR` deve vê-lo, por operar o Kanban/fila lado a lado com o `AdminOperacional`.
- **Tenant-scoped:** restrito ao `obraId` da claim do JWT, como `Operador`/`Empreiteiro` — **sem** bypass cross-tenant.
- **Provisionamento (DEC-048):** usuários `TOWER_OPERATOR` são criados/desativados na tela dedicada do módulo (`/machinery-link/{obraId}/tower-operators`), obra-scoped, pelo mesmo contrato `POST /usuarios` (perfil `TowerOperator`, `obraId` derivado do path) — não mais pela tela de plataforma (`/ops/usuarios`, restrita a `SuperAdmin`/`Board` desde DEC-048). RBAC inalterado (`USUARIO_WRITE_PERFIS`).
- **Escrita — 2ª exceção `machinery:operador-setor:update` (carve-out — DEC-058, molde DEC-040):** o `TOWER_OPERATOR` pode editar os setores de atuação de um operador via `PATCH /operadores/:id/setores` (`{ setoresIds: string[] }`, replace-whole-set, mesma obra do JWT, **sem** bypass de tenant) — realocar operador de rua conforme a frente de obra avança é tarefa rotineira de quem orquestra a fila. **Não** ganha acesso ao CRUD completo de Operador (`POST`/`PATCH /operadores` seguem restritos a `AdminOperacional`/`SuperAdmin`); o carve-out é estrito ao vínculo de setores.

[1] Apenas sobre usuários pertencentes à mesma obra e com perfil hierárquico inferior ou igual.
[2] Permitido estritamente para leitura de registros da sua autoria ou inerentes ao seu cadastro/entidade.
[3] Permitido apenas se o operador autenticado estiver a agir sobre o seu próprio expediente ou sobre demandas visíveis ativamente alocadas na fila.
[4] Permitido ao `Empreiteiro` apenas se a demanda for da sua autoria e estritamente enquanto estiver no estado inicial `PENDENTE`.
[5] Permitido apenas para consultar relatórios formatados ou metadados do seu próprio vínculo.
[6] Permitido ao `Operador` apenas sobre a demanda que está atualmente em `EM_ANDAMENTO` sob sua responsabilidade; justificativa obrigatória (DEC-019).
[7] Permitido ao `Operador` apenas sobre demanda agendada que ele já aceitou (vinculada ao seu expediente); a solicitação fica pendente de aprovação do `AdminOperacional` ou `SuperAdmin` (DEC-029).
[8] `TOWER_OPERATOR` (carve-out MVP-15jul — DEC-040, amenda DEC-039): cria Demanda via `POST /demandas` (estado inicial `PENDENTE`, free-text), única escrita liberada ao perfil — ver subseção "Perfil TOWER_OPERATOR". A coluna dedicada na matriz será adicionada com a tela da Torre (Slice 6); até lá o `✓` do perfil vive nesta nota + na subseção. Demais escritas permanecem ✗.
[9] `core:obra:configuracoes` (DEC-050): edição da janela de expediente (`GET/PATCH /obras/:id/configuracoes`) — liberada a `AdminOperacional` **além** de `SuperAdmin`, diferente de `core:obra:update` (só `SuperAdmin`). Escopo restrito aos 4 campos de expediente (`expedienteInicio`/`expedienteFim`/`limiteHoraExtraMin`/`diasAtivos`); não permite editar demais dados da obra.
[10] `machinery:empreiteira:read` — `Empreiteiro` **removido** do read (amendment 2026-07-08, global-catalog): o catálogo de empreiteiras deixou de ser legível por `Empreiteiro`/`Operador`/`TOWER_OPERATOR`. Fonte única `EMPREITEIRA_READ_PERFIS` (`packages/types/src/perfis.ts`) = `SuperAdmin`/`Board`/`AdminOperacional`/`UsuarioInternoFGR`. Antes desta mudança o `Empreiteiro` tinha `✓*[2]` (leitura da própria entidade).
[11] `machinery:prontidao:read` (DEC-046, alargado DEC-052): `GET /obras/:obraId/prontidao`, fonte única `PRONTIDAO_READ_PERFIS`. `SuperAdmin`/`Board` cross-tenant (overview da shell, uma chamada por obra); **+ `TOWER_OPERATOR`** — que não tem coluna na matriz, ver subseção "Perfil TOWER_OPERATOR". `UsuarioInternoFGR` fora (não opera a fila).
[12] `machinery:operador-setor:update` (carve-out — DEC-058, molde DEC-040): `PATCH /operadores/:id/setores` (`{ setoresIds: string[] }`, replace-whole-set) — liberado a `SuperAdmin`, `AdminOperacional` **e `TOWER_OPERATOR`** (que não tem coluna na matriz, ver subseção "Perfil TOWER_OPERATOR"). Carve-out cirúrgico: mesma obra do JWT, sem bypass de tenant; `TOWER_OPERATOR` segue **sem** acesso ao restante do CRUD de Operador (`machinery:operador:create`/`update`/`delete` permanecem ✗ para o perfil).

> **Amendment 2026-07-11 — Slice 7:** o carve-out `TOWER_OPERATOR` se estende a `machinery:demanda:cancel` e a `devolver` (via `PATCH /demandas/:id/estado`) — sempre mesma obra, sem bypass de tenant. `update`/`delete`/`export` seguem ✗. Ver DEC tática `memory/decisions/2026-07-10-slice-7-transicoes-http-ui.md` (ponto 1).

## Matriz de permissões condicionadas ao estado da demanda

> *Esta seção resolveu a Lacuna 2 identificada em audit 2026-03-26.*

A tabela abaixo exibe exaustivamente o cruzamento do recurso `demanda` por `EstadoAtual`, `Ação` requerida e perfis autorizados. Qualquer tentativa de transição ou ação restrita não abordada aqui denota rejeição pelo Guard na infraestrutura NestJS.

| Estado | Ação | Perfis autorizados | Condição adicional |
| :--- | :--- | :--- | :--- |
| `[*]` (nulo) | `create` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro`, `TOWER_OPERATOR` | Cria e transita o fluxo em `PENDENTE`. Apenas `AdminOperacional` e `SuperAdmin` podem incluir `dataAgendada` para cair em `AGENDADA` (DEC-020). `TOWER_OPERATOR` cria sempre em `PENDENTE`, sem `dataAgendada` (carve-out MVP-15jul — DEC-040, amenda DEC-039). |
| `AGUARDANDO_APROVACAO` | `approve` | `SuperAdmin`, `AdminOperacional` | Aprova agendamento criado por `UsuarioInternoFGR`; demanda transita para `AGENDADA`. (DEC-027) |
| `AGUARDANDO_APROVACAO` | `reject` | `SuperAdmin`, `AdminOperacional` | Rejeita agendamento; demanda transita para `CANCELADA` com justificativa obrigatória. (DEC-027) |
| `AGENDADA` | `aceitar` | `Operador` | Operador compatível por `TipoMaquinario` aceita a demanda agendada; fica vinculado ao slot. Bloqueado se operador já tiver demanda aceita no mesmo slot (janela de conflito configurável por obra — DEC-026 Q9). Se `operadorAlocadoId` presente, ação ignorada (bypass — DEC-026 Q3). (DEC-026) |
| `AGENDADA` | `recusar` | `Operador` | Operador recusa demanda agendada; demanda permanece na aba "Demandas Agendadas". Log: `RECUSADA` por operador. Recusa não remove a demanda nem bloqueia outros operadores. (DEC-026 Q2) |
| `AGENDADA` | `update` | `SuperAdmin`, `AdminOperacional` | Permite correções do agendamento, do horário cravado ou realocações manuais. |
| `AGENDADA` | `cancel` | `SuperAdmin`, `AdminOperacional` | Cancela diretamente a demanda ainda dormente e futura da esteira. Justificativa obrigatória no log. |
| `AGENDADA` | `allocate` / `antecipar` | `SuperAdmin`, `AdminOperacional` | Bypass manual coercivo injetando preemptivamente o agendamento em `PENDENTE` em tempo real. |
| `AGENDADA` (aceita) | `cancel-request` | `Operador` | Operador solicita cancelamento de demanda agendada que já aceitou; solicitação fica pendente de aprovação. (DEC-029 Q6/Q8) |
| `AGENDADA` (aceita) | `approve` (cancel) | `SuperAdmin`, `AdminOperacional` | Aprova solicitação de cancelamento do operador; demanda transita para `CANCELADA`. (DEC-029) |
| `AGENDADA` (aceita) | `reject` (cancel) | `SuperAdmin`, `AdminOperacional` | Rejeita solicitação de cancelamento; demanda permanece `AGENDADA` e vinculada ao operador. (DEC-029) |
| `NAO_EXECUTADA` | mutação | nenhum | Estado terminal para demandas agendadas sem aceite até T-1h. Log por operador: `RECUSADA` ou `NAO_RESPONDIDA`. Impede quaisquer modificações subsequentes. (DEC-028) |
| `[*]` | `read` / `export` | `SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro`, `Operador` | Visualização geral ou condicional ao perfil; `Operador` e `Empreiteiro` restritos à própria posse. |
| `PENDENTE` | `update` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` | Administradores podem corrigir alocações etc.; `Empreiteiro` pode alterar ordens exclusivamente criadas por si. |
| `PENDENTE` | `cancel` | `SuperAdmin`, `AdminOperacional`, `Empreiteiro` | Transita para `CANCELADA`. Justificativa sempre guardada no log. |
| `PENDENTE` | `allocate` | `SuperAdmin`, `AdminOperacional` | Bypass manual coercivo (Regra Zero), injetando `operadorAlocadoId`. |
| `PENDENTE` | `iniciar` | `Operador` | Permite engajamento estritamente ao operador que recebeu a demanda como topo da fila ou por alocação explícita. |
| `EM_ANDAMENTO` | `update` | `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR` | Útil para corrigir metadados sem devolver o serviço em execução. |
| `EM_ANDAMENTO` | `concluir` | `Operador` | Transita terminalmente para `CONCLUIDA`; restrito ao operador atualmente vinculado. |
| `EM_ANDAMENTO` | `cancel` | `Operador`, `AdminOperacional`, `SuperAdmin` | Transita diretamente para `CANCELADA` com justificativa obrigatória. Para o `Operador`, restrito à demanda sob sua responsabilidade (DEC-019). |
| `EM_ANDAMENTO` | `devolver` | `SuperAdmin`, `AdminOperacional` | Força administrativa que aliena o operador da execução e reinjeta a demanda após `RETORNADA`. |
| `CONCLUIDA` | mutação | nenhum | Demanda terminal concluída para uso contábil e de medição; ações reescreventes, operacionais e destrutivas perdem validade. |
| `CANCELADA` | mutação | nenhum | Demanda finalizada como supressa; impede modificações subsequentes. |

> **Amendment 2026-07-11 — Slice 7:** linhas acima ganham extensão de perfil e novo estado de origem:
> - `PENDENTE` / `EM_ANDAMENTO` | `cancel` | **+ `TOWER_OPERATOR`** — sempre mesma obra, sem bypass de tenant (extensão DEC-040).
> - `PAUSADA` | `cancel` | `Operador`, `AdminOperacional`, `SuperAdmin`, `TOWER_OPERATOR` | Mesma regra de `EM_ANDAMENTO → cancel` (execução em curso); justificativa obrigatória. Ownership: `Operador` restrito à demanda sob sua responsabilidade (`atorOperadorId === operadorAtribuidoId`, DEC-019); `Empreiteiro` não se aplica (`PAUSADA` não é demanda de sua criação em aberto).
> - `PAUSADA` | `devolver` | `SuperAdmin`, `AdminOperacional`, `TOWER_OPERATOR` | Transição direta e atômica para `PENDENTE` (sem persistir `RETORNADA`) — ver SPEC/03 amendment 2026-07-11.
> - `EM_ANDAMENTO` | `devolver` | destino corrigido para `PENDENTE` (não mais `RETORNADA`) — mesma nota acima; `+ TOWER_OPERATOR`.
> - Ownership formalizada para `cancel`: `Empreiteiro` restrito a `atorId === criadoPorId` (demanda que criou).
>
> Ver DEC tática `memory/decisions/2026-07-10-slice-7-transicoes-http-ui.md` (pontos 1–3).

> **Amendment 2026-07-15 — pré-alocação na criação (gestão):** `POST /demandas` aceita
> `operadorId?` apenas para `TOWER_OPERATOR`, `ADMIN_OPERACIONAL` e `SUPER_ADMIN` — na prática,
> `create` com pré-alocação embutida equivale a `create`+`allocate` atômicos para o trio de
> gestão (linha `[*] create` + linha `PENDENTE allocate` desta matriz, num só request).
> `UsuarioInternoFGR` e `Empreiteiro` continuam criando SEM `operadorId` (envio → `403 RBAC-001`).
> Ver design `docs/superpowers/specs/2026-07-15-criar-demanda-gestao-design.md`.

## Decisões de design

> Decisão: Agrupamos os domínios hierárquicos e recursos territoriais (`lote-adjacencia`, `rua`, `quadra`, `lote` e `setor-operacional`) espelhando as mesmas restrições exatas do cadastro base (apenas `AdminOperacional` e `SuperAdmin` criam/alteram), visto que mapeiam imutáveis da obra.
>
> Decisão: A ação `export` foi liberada para gestores de obra e diretoria, mas proibida para `Empreiteiro` e `Operador` por escopo concorrencial e finalidade puramente operacional.
>
> ~~Decisão: O recurso `solicitacao-cancelamento` foi blindado para manter design coeso de REST API de cancel-requests independentes por ID.~~ *(Removido do MVP por DEC-019 — 2026-04-13. O cancelamento é feito diretamente no aggregate root `Demanda` com justificativa obrigatória.)*
>
> Decisão: A matriz explicita ações inativas/inexistentes com `—` para anular inferências indevidas no momento de instanciar metadados de Guards e decorators.
>
> Decisão (leitura de contexto para perfis de campo): `Empreiteiro` e `Operador` possuem permissão de leitura (`read`) em recursos de contexto como `core:obra`, `core:setor-operacional`, `core:quadra`, `core:lote`, `core:rua`, `machinery:maquinario`, `machinery:servico` e `machinery:material`. Essa abertura é estritamente funcional e aderente ao escopo restrito definido no PRD (`REQ-RBAC-005` e `REQ-RBAC-006`): o `Empreiteiro` necessita consultar obra, hierarquia territorial e catálogos para preencher o formulário de abertura de demanda; o `Operador` necessita consultar obra, setor operacional, quadra, lote, maquinário e serviços para visualizar a fila operacional e executar demandas. Todas estas leituras são limitadas ao tenant da obra atribuída — não há bypass cross-tenant — e servem exclusivamente como contexto auxiliar de preenchimento ou visualização, sem conceder capacidade de mutação, exportação ou acesso a dados de outros perfis.
>
> Decisão (demandas agendadas — DEC-026, DEC-027, DEC-029): As ações `aceitar`, `recusar` e `cancel-request` sobre demandas `AGENDADA` são modeladas na matriz de estado condicional (não como colunas adicionais na matriz de recursos) porque dependem fundamentalmente do estado da demanda e do vínculo do operador. O broadcast de aceite opera por `TipoMaquinario` sem filtro de setor. Fechar o pop-up de aceite é equivalente a adiar a decisão — não registra recusa. O estado `AGUARDANDO_APROVACAO` introduzido pela DEC-027 intercede entre a criação pelo `UsuarioInternoFGR` e a efetivação do agendamento, garantindo aprovação explícita do `AdminOperacional` ou `SuperAdmin`. O estado terminal `NAO_EXECUTADA` (DEC-028) cobre demandas agendadas sem aceite até T-1h, com log de `NAO_RESPONDIDA` por operador. O fluxo de `cancel-request` sobre demandas agendadas (DEC-029) aplica-se apenas ao `Operador` que já aceitou a demanda e é distinto e complementar ao cancelamento direto do `AdminOperacional`/`SuperAdmin` (DEC-019).

**Rastreio PRD:** `REQ-RBAC-004`, `REQ-RBAC-006`
