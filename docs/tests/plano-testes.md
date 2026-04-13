# Plano de Testes — FGR-Ops Machinery Link

Mapeamento dos critérios de aceite (`REQ-ACE-*`) definidos em `PRD/05-criterios-aceite.md` para casos de teste de integração e E2E.

**PRD fonte:** [../PRD/05-criterios-aceite.md](../PRD/05-criterios-aceite.md)

**Referências de contratos:** [../SPEC/08-api-contratos.md](../SPEC/08-api-contratos.md), [../SPEC/04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md)

---

## Convenções

| Tipo | Descrição |
|------|-----------|
| **INT** | Integração — testa um endpoint real contra banco de dados de teste |
| **E2E** | End-to-end — testa fluxo completo via browser/app simulado |
| **UNIT** | Unitário — testa lógica de domínio isolada (sem I/O) |

Fixtures base necessárias para todos os suites:
- Obra com `expedienteInicio=06:00`, `expedienteFim=17:00`
- Perfis: `SuperAdmin`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro`, `Operador`, `Board`
- SetorOperacional, Quadra, Lote, LocalExterno cadastrados
- Maquinário e Serviço compatíveis cadastrados

---

## REQ-ACE-001 — Isolamento RBAC e multi-tenancy

→ SPEC: [../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass](../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass)

### ACE-001-1: Isolamento de dados entre Empreiteiros `[INT]`

```gherkin
Given que o usuário está autenticado com o perfil 'Empreiteiro' vinculado à 'Obra A'
When o usuário solicita a listagem de demandas ativas no sistema
Then o sistema deve retornar apenas as demandas cujo campo 'obraId' seja igual ao ID da 'Obra A'
```

**Endpoint:** `GET /api/v1/demandas`
**Fixture:** 2 obras com demandas distintas; Empreiteiro vinculado apenas à Obra A
**Validação:** nenhuma demanda da Obra B aparece na resposta

### ACE-001-2: Visibilidade Cross-tenant para Board `[INT]`

```gherkin
Given que o usuário está autenticado com o perfil 'Board'
When o usuário acessa o dashboard global de produtividade
Then o sistema deve exibir dados agregados de todas as obras cadastradas sem restrição de tenant
```

**Endpoint:** `GET /api/v1/relatorios/sla` (sem `X-Obra-Id`)
**Validação:** resposta inclui dados de ≥ 2 obras distintas

---

## REQ-ACE-002 — Máquina de estados: bloqueio de bypass pós-conclusão

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### ACE-002-1: Tentativa de cancelamento em demanda concluída `[INT]`

```gherkin
Given que uma demanda possui o status atual 'CONCLUIDA'
When um usuário com perfil 'Operador' tenta executar a ação 'CANCELAR' nesta demanda
Then o sistema deve rejeitar a transição e retornar uma mensagem de erro de permissão de estado
```

**Endpoint:** `PATCH /api/v1/demandas/:id/estado` com `{ "acao": "cancelar" }`
**Fixture:** demanda no estado `CONCLUIDA`; token de Operador
**Validação:** `HTTP 409` com código de erro `DEM-003`

### ACE-002-2: Guard de máquina de estados no domínio `[UNIT]`

**Alvo:** módulo de domínio `DemandaStateMachine`
**Cenários:** todas as transições inválidas da tabela em SPEC/03 devem lançar `InvalidTransitionError`

---

## REQ-ACE-003 — Jurisdição logística sobre preferências no score

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### ACE-003-1: Adjacência supera demanda alocada manualmente na ordenação `[INT]`

```gherkin
Given que um Operador possui na fila demanda 'A' (operadorAlocadoId, quadra diferente)
  e demanda 'B' (sem alocação manual, mesma quadra — fator_adjacencia=1.0)
When o motor de scoring calcula a pontuação para a fila
Then a demanda 'B' deve receber pontuação superior à demanda 'A'
```

**Endpoint:** `GET /api/v1/operadores/:id/fila`
**Validação:** `posicao` da demanda B < posicao da demanda A

### ACE-003-2: Alocação manual fora de zona — exceção auditável `[INT]`

```gherkin
Given que AdminOperacional cria demanda com operadorAlocadoId fora do SetorOperacional
When a demanda é criada
Then retorna HTTP 201 (sem rejeição) e gera registo auditável da excepção de jurisdição
```

**Endpoint:** `POST /api/v1/demandas`
**Validação:** resposta `201`, `DemandaLog` contém entrada com tipo `EXCECAO_JURISDICAO`

---

## REQ-ACE-004 — Audit log com justificativa em modificações gerenciais

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)

### ACE-004-1: Registo de alteração administrativa `[INT]`

```gherkin
Given que um 'AdminOperacional' altera o 'OperadorAlocado' de uma demanda existente
When o Admin confirma a alteração com justificativa obrigatória
Then o sistema deve criar registo em DemandaLog com userId, timestamp, valores antigo/novo e justificativa
```

**Endpoint:** `PATCH /api/v1/demandas/:id/estado` com `{ "acao": "devolver", "justificativa": "..." }`
**Validação:** `GET /api/v1/demandas/:id` retorna `DemandaLog` com entrada de `devolver` e justificativa

### ACE-004-2: Rejeição de transição sem justificativa obrigatória `[INT]`

**Endpoint:** `PATCH /api/v1/demandas/:id/estado` com `{ "acao": "cancelar" }` sem `justificativa`
**Fixture:** demanda em `PENDENTE`; Empreiteiro autenticado
**Validação:** `HTTP 400` com código `DEM-004`

---

## REQ-ACE-005 — Destaque visual de prioridade máxima na UI mobile

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### ACE-005-1: Fila retorna demanda MAXIMA com flag de destaque `[INT]`

```gherkin
Given que existem 3 demandas na fila do Operador, sendo uma de prioridade 'MAXIMA'
When o Operador acessa GET /operadores/:id/fila
Then a demanda MAXIMA deve aparecer em posicao=1 com campo prioridade='MAXIMA'
  e as outras 2 demandas devem aparecer nas posições seguintes (lista não truncada)
```

**Endpoint:** `GET /api/v1/operadores/:id/fila`
**Validação:** `fila.length === 3`; `fila[0].prioridade === 'MAXIMA'`

### ACE-005-2: UI mostra borda pulsante e fila completa `[E2E]`

**Componente:** `OperadorFilaView` (Angular 20)
**Validação:** elemento com classe `.status-danger` visível no topo; componentes das demandas 2 e 3 renderizados abaixo e acessíveis via scroll (não ocultos)

---

## REQ-ACE-006 — Cancelamento de demanda em execução pelo operador (DEC-019)

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### ACE-006-1: Cancelamento direto pelo Operador com justificativa `[INT]`

```gherkin
Given que um 'Operador' cancela demanda em 'EM_ANDAMENTO' com justificativa preenchida
When a requisição é enviada
Then status transita para 'CANCELADA'
  And DemandaLog registra ator, timestamp e motivo
  And operador fica disponível para próxima tarefa da fila
```

**Endpoint:** `PATCH /api/v1/demandas/:id/estado` com `{ "acao": "cancelar", "justificativa": "..." }`
**Validação:** `HTTP 200`; `statusNovo === 'CANCELADA'`; `DemandaLog` contém `{ ator, timestamp, motivo }`

### ACE-006-2: Bloqueio de cancelamento sem justificativa `[INT]`

```gherkin
Given que um 'Operador' tenta cancelar demanda em 'EM_ANDAMENTO' sem justificativa
When a requisição é enviada
Then sistema retorna HTTP 422 e demanda permanece em 'EM_ANDAMENTO'
```

**Endpoint:** `PATCH /api/v1/demandas/:id/estado` com `{ "acao": "cancelar" }` (sem justificativa)
**Validação:** `HTTP 422`; `statusAtual === 'EM_ANDAMENTO'` inalterado
**Validação:** resposta contém `DemandaLog` com campos `origem`, `ator`, `timestamp`

---

## REQ-ACE-007 — Segurança de token e gestão de sessão

→ SPEC: [../SPEC/00-visao-arquitetura.md#decisoes-arquiteturais-adrs](../SPEC/00-visao-arquitetura.md#decisoes-arquiteturais-adrs)

### ACE-007-1: Expiração e renovação de access token `[INT]`

```gherkin
Given que usuário possui access token válido
When o access token expira após 15 min (clock mockado)
Then requisição retorna HTTP 401
  And renovação via refresh token retorna novo par de tokens
  And refresh token anterior é invalidado
```

**Endpoints:** `POST /auth/refresh`; validação de `jti` na blacklist Redis

### ACE-007-2: Invalidação imediata por logout `[INT]`

**Endpoint:** `POST /auth/logout`
**Validação:** token adicionado à blacklist Redis; requisição seguinte com mesmo token retorna `401`

### ACE-007-3: Detecção de reuso de refresh token `[INT]`

**Fixture:** refresh token já utilizado (rotacionado)
**Validação:** segunda utilização retorna `401`; toda a cadeia de tokens do usuário invalidada; evento em `AuthAuditLog`

---

## REQ-ACE-008 — Isolamento Cross-Tenant Auditado

→ SPEC: [../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass](../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass)

### ACE-008-1: Auditoria de acesso cross-tenant `[INT]`

```gherkin
Given que SuperAdmin ou Board acessa dados de múltiplas obras
When a consulta é executada
Then sistema regista evento em AuditLogCrossTenant com userId, role, endpoint, obraIdAlvo, timestamp
```

**Validação:** entrada em `AuditLogCrossTenant` criada após cada acesso cross-tenant

### ACE-008-2: Board bloqueado para verbos de escrita `[INT]`

```gherkin
Given que usuário com perfil 'Board' tenta POST/PUT/PATCH/DELETE
When Guard avalia a requisição
Then sistema retorna HTTP 403 independentemente do payload
```

**Endpoints:** `POST /api/v1/demandas`, `PATCH /api/v1/demandas/:id/estado`
**Validação:** `HTTP 403` antes de atingir o controlador

---

## Tabela de cobertura

| REQ-ACE | Cenários | Tipo | Endpoint / Componente alvo |
|---------|----------|------|---------------------------|
| ACE-001 | 2 | INT | `GET /demandas`, `GET /relatorios/sla` |
| ACE-002 | 2 | INT, UNIT | `PATCH /demandas/:id/estado`, `DemandaStateMachine` |
| ACE-003 | 2 | INT | `POST /demandas`, `GET /operadores/:id/fila` |
| ACE-004 | 2 | INT | `PATCH /demandas/:id/estado` |
| ACE-005 | 2 | INT, E2E | `GET /operadores/:id/fila`, `OperadorFilaView` |
| ACE-006 | 3 | INT | `PATCH /demandas/:id/estado`, job scheduler, `GET /relatorios/cancelamentos` |
| ACE-007 | 3 | INT | `POST /auth/refresh`, `POST /auth/logout` |
| ACE-008 | 2 | INT | `GET /relatorios/sla`, `POST /demandas` |
| **Total** | **18** | | |
