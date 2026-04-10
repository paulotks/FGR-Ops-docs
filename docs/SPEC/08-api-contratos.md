---
id: 08-api-contratos
title: Contratos de API REST
area: Backend / Integração
---

# Contratos de API REST

**Rastreio PRD:** `REQ-NFR-005`, `REQ-NFR-006`, `REQ-NFR-007`, `REQ-FUNC-001`, `REQ-FUNC-002`, `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-005`, `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-009`, `REQ-FUNC-010`, `REQ-FUNC-011`, `REQ-FUNC-012`, `REQ-RBAC-001…006`

Este módulo define os contratos de interface REST do `apps/api` (NestJS). Os schemas de request/response são validados via **Zod** ou **Valibot**, partilhados com o frontend Angular 20 através dos pacotes `packages/types` no monorepo (D1).

---

## 1. Convenções gerais

| Convenção | Valor |
|-----------|-------|
| Base URL | `/api/v1` |
| Autenticação | `Authorization: Bearer <access_token>` (JWT) |
| Content-Type | `application/json` |
| Erros | Objeto `{ statusCode, message, error?, details? }` |
| Tenant scope | Header `X-Obra-Id` injetado pelo middleware (D4); ignorado para `SuperAdmin`/`Board` (D5) |
| Paginação | Query params `?page=1&limit=20`; resposta inclui `{ data[], total, page, limit }` |
| Timestamps | ISO 8601, timezone `America/Sao_Paulo` |

### Códigos de resposta globais

| HTTP | Semântica |
|------|-----------|
| `200 OK` | Leitura ou atualização com sucesso |
| `201 Created` | Recurso criado |
| `204 No Content` | Ação executada sem corpo de resposta |
| `400 Bad Request` | Payload inválido (falha de validação Zod/Valibot) |
| `401 Unauthorized` | Token ausente, expirado ou inválido |
| `403 Forbidden` | Perfil sem permissão para a ação solicitada |
| `404 Not Found` | Recurso não encontrado no tenant |
| `409 Conflict` | Transição de estado inválida (máquina de estados) |
| `422 Unprocessable Entity` | Regra de negócio violada (ex.: operador fora de setor) |
| `429 Too Many Requests` | Rate limit excedido; header `Retry-After` obrigatório |
| `500 Internal Server Error` | Erro interno não antecipado |

---

## 2. Autenticação (`/auth`)

### POST /auth/login — Login administrativo

**Rate limit:** 5 req/min por IP ou usuário → bloqueio 15 min (`REQ-NFR-006`, D3)

**Request:**
```json
{
  "email": "string",
  "password": "string (≥8 chars, 4 classes)"
}
```

**Response 200:**
```json
{
  "accessToken": "string (JWT, 15 min)",
  "refreshToken": "string (JWT, 7 dias)",
  "perfil": "AdminOperacional | UsuarioInternoFGR | SuperAdmin | Board",
  "obraId": "uuid | null (null para cross-tenant)"
}
```

**Erros específicos:** `401` credenciais inválidas (mensagem genérica) · `429` rate limit

---

### POST /auth/pin — Login de campo

**Rate limit:** 5 req/min por IP ou usuário → bloqueio progressivo (1/5/15 min) (`REQ-NFR-007`, D6)

**Request:**
```json
{
  "usuario": "string",
  "pin": "string (≥6 dígitos numéricos)"
}
```

**Response 200:**
```json
{
  "accessToken": "string (JWT, 15 min)",
  "refreshToken": "string (JWT, 12 h — campo)",
  "perfil": "Empreiteiro | Operador",
  "obraId": "uuid"
}
```

**Erros específicos:** `401` credenciais inválidas (mensagem genérica, não enumerável) · `429` lockout progressivo

---

### POST /auth/refresh — Renovar tokens

**Request:**
```json
{ "refreshToken": "string" }
```

**Response 200:** igual ao login (novos access + refresh tokens — rotação a cada uso, D3)

**Erros:** `401` token inválido/expirado/revogado

---

### POST /auth/logout — Revogar sessão

**Headers:** `Authorization: Bearer <access_token>`

**Response 204** — token adicionado à blacklist Redis (jti, D3)

---

## 3. Demandas (`/demandas`)

**Rate limit criação:** 20 req/min por usuário autenticado (D3, `REQ-NFR-006`)

### POST /demandas — Criar demanda

**Perfis:** `Empreiteiro`, `AdminOperacional`, `UsuarioInternoFGR`

**Request (CreateDemandaDto):**
```json
{
  "servicoId": "uuid",
  "maquinarioId": "uuid",
  "localTipo": "QUADRA_LOTE | LOCAL_EXTERNO",
  "quadraId": "uuid | null",
  "loteId": "uuid | null",
  "localExternoId": "uuid | null",
  "materialId": "uuid | null (opcional)",
  "destinoQuadraId": "uuid | null (obrigatório se exigeTransporte=true e transporteInterno=false)",
  "destinoLoteId": "uuid | null (obrigatório se exigeTransporte=true e transporteInterno=false)",
  "transporteInterno": "boolean | null (disponível apenas se exigeTransporte=true; indica destino = origem)",
  "descricaoAdicional": "string | null (opcional, recomendado para movimentação)",
  "urgencia": "ASAP | AGENDADA",
  "dataAgendada": "ISO8601 | null (obrigatório se urgencia=AGENDADA)",
  "operadorAlocadoId": "uuid | null (apenas AdminOperacional / UsuarioInternoFGR)"
}
```

> `setorOperacionalId` é derivado automaticamente pelo backend a partir de `quadraId`/`loteId`/`localExternoId` (DEC-005).

**Response 201:**
```json
{
  "id": "uuid",
  "status": "PENDENTE | AGENDADA",
  "score": "number",
  "setorOperacionalId": "uuid",
  "criadoEm": "ISO8601"
}
```

**Erros:** `400` validação DTO · `422` operador fora de setor (com alerta, não bloqueio — DEC-001) · `422` incompatibilidade serviço/maquinário · `422` destino ausente para serviço com `exigeTransporte=true` (`DEM-005`)

---

### POST /demandas/bulk — Criar múltiplas demandas

**Perfis:** `AdminOperacional`, `UsuarioInternoFGR`
**Rate limit:** incluído no limite de 20 req/min

**Request (CreateMultipleDemandasDto):**
```json
{
  "demandas": [ /* array de CreateDemandaDto */ ],
  "grupoNome": "string | null"
}
```

**Response 201:**
```json
{
  "grupoId": "uuid | null",
  "criadas": [ { "id": "uuid", "status": "string" } ],
  "erros": [ { "index": "number", "mensagem": "string" } ]
}
```

---

### GET /demandas — Listar demandas

**Perfis:** todos (escopo filtrado por perfil/obraId)

**Query params:** `?status=&operadorId=&servicoId=&setorId=&page=&limit=`

**Response 200:** lista paginada de demandas com campos principais (id, status, score, localTipo, criadoEm, empreiteiro, operador)

---

### GET /demandas/:id — Detalhe de demanda

**Response 200:** demanda completa incluindo `DemandaLog[]`

**Erros:** `404` não encontrada no tenant

---

### PATCH /demandas/:id/estado — Transição de estado

**Perfis e transições autorizadas:** conforme tabela em [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md#tabela-de-transicoes-por-perfil)

**Request (TransicaoEstadoDto):**
```json
{
  "acao": "iniciar | concluir | cancelar | devolver | solicitar_cancelamento | aprovar_cancelamento | rejeitar_cancelamento | antecipar",
  "justificativa": "string | null (obrigatório para acoes auditaveis)"
}
```

**Response 200:**
```json
{
  "id": "uuid",
  "statusAnterior": "string",
  "statusNovo": "string",
  "logId": "uuid"
}
```

**Erros:** `409` transição inválida na máquina de estados · `403` perfil sem permissão para esta transição

---

## 4. Operadores (`/operadores`)

### GET /operadores/:id/fila — Fila do operador

**Perfis:** `Operador` (própria fila), `AdminOperacional`, `UsuarioInternoFGR`, `SuperAdmin`

**Response 200:**
```json
{
  "operadorId": "uuid",
  "expedienteAtivo": "boolean",
  "fila": [
    {
      "demandaId": "uuid",
      "posicao": "number",
      "score": "number",
      "prioridade": "NORMAL | ELEVADA | MAXIMA",
      "slaVencimentoEm": "ISO8601 | null",
      "slaViolado": "boolean"
    }
  ]
}
```

---

### GET /operadores — Listar operadores disponíveis

**Query params:** `?setorId=&turnoAtivo=`

**Response 200:** lista de operadores com `disponivel`, `setorOperacionalId`, `maquinarioAtualId`

---

### POST /operadores/:id/checkin — Check-in de expediente

**Perfil:** `Operador`

**Request:**
```json
{
  "maquinarioId": "uuid",
  "ajudanteId": "uuid | null"
}
```

**Response 201:** `RegistroExpediente` criado com `id`, `inicioEm`

**Erros:** `409 OPR-003` check-in duplicado no mesmo turno

---

### POST /operadores/:id/checkout — Checkout de expediente

**Rastreio PRD:** `REQ-FUNC-004`

**Perfil:** `Operador`

**Request:**
```json
{
  "ajudanteId": "uuid | null"
}
```

> Campo `ajudanteId` opcional — usado apenas para registrar o ajudante ativo no encerramento, se diferente do informado no check-in.

**Response 200:**
```json
{
  "expedienteId": "uuid",
  "fimEm": "ISO8601",
  "totalDemandas": "number"
}
```

**Erros:** `404 OPR-004` sem expediente ativo · `409 OPR-005` demanda em `EM_ANDAMENTO` ou `PAUSADA` pendente de conclusão — encerrar ou retornar a demanda antes do checkout

---

## 5. Obras e recursos espaciais (`/obras`)

### GET /obras/:id — Detalhe de obra

**Response 200:** obra com `setoresOperacionais[]`, `expedienteInicio`, `expedienteFim`

---

### GET /obras/:id/setores — Setores operacionais

**Response 200:** lista de `SetorOperacional` com `quadras[]` e `locaisExternos[]`

---

### GET /obras/:id/fila — Fila global da obra (kanban administrativo)

**Rastreio PRD:** `REQ-FUNC-001`, `REQ-FUNC-002`, `REQ-FUNC-008`

**Perfis:** `AdminOperacional`, `UsuarioInternoFGR`, `SuperAdmin`

> Corresponde ao kanban em tempo real descrito em [07-design-ui-logica.md](07-design-ui-logica.md). Retorna todas as demandas ativas da obra com posição de fila, score e status de SLA, permitindo supervisão e filtragem cruzada.

**Query params:** `?status=&setorId=&operadorId=&prioridade=&page=&limit=`

| Param | Tipo | Descrição |
|-------|------|-----------|
| `status` | `string` | Filtrar por estado (`PENDENTE`, `EM_ANDAMENTO`, `PAUSADA`, `AGENDADA`, `PENDENTE_APROVACAO`) |
| `setorId` | `uuid` | Filtrar por setor operacional |
| `operadorId` | `uuid` | Filtrar por operador alocado |
| `prioridade` | `string` | Filtrar por nível SLA (`NORMAL`, `ELEVADA`, `MAXIMA`) |
| `page` | `number` | Página (padrão 1) |
| `limit` | `number` | Itens por página (padrão 20, máx 100) |

**Response 200:**
```json
{
  "data": [
    {
      "demandaId": "uuid",
      "posicao": "number",
      "score": "number",
      "status": "PENDENTE | EM_ANDAMENTO | PAUSADA | AGENDADA | PENDENTE_APROVACAO",
      "prioridade": "NORMAL | ELEVADA | MAXIMA",
      "slaVencimentoEm": "ISO8601 | null",
      "slaViolado": "boolean",
      "operadorId": "uuid | null",
      "operadorNome": "string | null",
      "setorOperacionalId": "uuid",
      "empreiteiroNome": "string",
      "servicoNome": "string",
      "criadoEm": "ISO8601"
    }
  ],
  "total": "number",
  "page": "number",
  "limit": "number"
}
```

**Erros:** `404` obra não encontrada no tenant

---

### PATCH /obras/:id/configuracoes — Atualizar configurações da obra

**Rastreio PRD:** `REQ-FUNC-001`, `REQ-FUNC-002`, `REQ-FUNC-004`

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateObraConfiguracoesDto):**
```json
{
  "expedienteInicio": "HH:MM | null",
  "expedienteFim": "HH:MM | null",
  "pesoAdjacencia": "number (0.0–1.0) | null",
  "pesoServico": "number (0.0–1.0) | null",
  "pesoMaterial": "number (0.0–1.0) | null"
}
```

> Campos omitidos mantêm o valor atual. Quando informados, os três pesos (`pesoAdjacencia + pesoServico + pesoMaterial`) devem somar exatamente `1.0`. Padrão do sistema: `W_adj = 0.5`, `W_srv = 0.3`, `W_mat = 0.2` (conforme [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md)).

**Response 200:**
```json
{
  "obraId": "uuid",
  "expedienteInicio": "HH:MM",
  "expedienteFim": "HH:MM",
  "pesoAdjacencia": "number",
  "pesoServico": "number",
  "pesoMaterial": "number"
}
```

**Erros:** `400` pesos não somam 1.0 · `404` obra não encontrada · `422` `expedienteInicio` igual ou posterior a `expedienteFim`

---

### POST /obras/:id/fila/recalcular — Forçar recálculo de scores pendentes

**Rastreio PRD:** `REQ-FUNC-001`, `REQ-FUNC-002`

**Perfis:** `AdminOperacional`, `SuperAdmin`

> Força o recálculo dos scores de todas as demandas em `PENDENTE` e `AGENDADA` da obra, aplicando os pesos de fila atuais. Útil após alteração de configurações (`PATCH /obras/:id/configuracoes`) ou ajustes manuais de adjacência. Mencionado em [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md).

**Request:** sem body

**Response 200:**
```json
{
  "obraId": "uuid",
  "demandasRecalculadas": "number",
  "recalculadoEm": "ISO8601"
}
```

**Erros:** `404` obra não encontrada

---

### GET /tipos-maquinario — Listar tipos de maquinário

**Perfis:** todos (catálogo global)

**Query params:** `?page=&limit=`

**Response 200:** lista de `TipoMaquinario` com `id`, `nome`, `descricao`, `servicos[]`

---

### POST /tipos-maquinario — Criar tipo de maquinário

**Perfis:** `SuperAdmin`, `AdminOperacional`

**Request (CreateTipoMaquinarioDto):**
```json
{
  "nome": "string (obrigatório)",
  "descricao": "string (obrigatório)"
}
```

**Response 201:** `TipoMaquinario` criado com `id`, `nome`, `descricao`

**Erros:** `400` campos obrigatórios ausentes · `409` nome duplicado

---

### PATCH /tipos-maquinario/:id — Atualizar tipo de maquinário

**Perfis:** `SuperAdmin`, `AdminOperacional`

**Request (UpdateTipoMaquinarioDto):** campos parciais de `CreateTipoMaquinarioDto`

**Response 200:** `TipoMaquinario` atualizado

**Erros:** `404` tipo não encontrado · `409` nome duplicado

---

### DELETE /tipos-maquinario/:id — Excluir tipo de maquinário (soft-delete)

**Perfis:** `SuperAdmin`, `AdminOperacional`

**Response 204**

**Erros:** `409` tipo possui maquinários ou serviços ativos vinculados

---

### GET /obras/:id/maquinarios — Catálogo de maquinários

**Query params:** `?disponivel=&tipoId=`

**Response 200:** lista de `Maquinario` com `id`, `nome`, `placa`, `proprietarioTipo`, `empreiteiraId`, `empreiteira` (objeto quando `proprietarioTipo = EMPREITEIRA`), `tipoMaquinario`, `servicos[]`

---

### POST /obras/:id/maquinarios — Criar maquinário

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateMaquinarioDto):**
```json
{
  "nome": "string (obrigatório)",
  "proprietarioTipo": "FGR | EMPREITEIRA (obrigatório)",
  "empreiteiraId": "uuid | null (obrigatório quando proprietarioTipo = EMPREITEIRA; null quando FGR)",
  "placa": "string | null (opcional)",
  "tipoMaquinarioId": "uuid (obrigatório)"
}
```

**Response 201:** `Maquinario` criado com `id`, `nome`, `placa`, `proprietarioTipo`, `empreiteiraId`, `tipoMaquinarioId`

**Erros:** `400` campos obrigatórios ausentes · `404` `tipoMaquinarioId` não encontrado

---

### PATCH /obras/:id/maquinarios/:maquinarioId — Atualizar maquinário

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateMaquinarioDto):** campos parciais de `CreateMaquinarioDto`

**Response 200:** `Maquinario` atualizado

**Erros:** `404` maquinário não encontrado no tenant

---

### DELETE /obras/:id/maquinarios/:maquinarioId — Excluir maquinário (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` maquinário possui expedientes ou demandas ativas

---

### GET /obras/:id/servicos — Catálogo de serviços

**Query params:** `?tipoMaquinarioId=` (filtragem por tipo — DEC-005/DEC-009)

**Response 200:** lista de `Servico` com `nome`, `descricao`, `prioridadeBase`, `exigeTransporte`, `tipoMaquinarioId`

---

### POST /obras/:id/servicos — Criar serviço

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateServicoDto):**
```json
{
  "nome": "string (obrigatório)",
  "descricao": "string (obrigatório)",
  "prioridade": "NORMAL | ELEVADA | MAXIMA",
  "exigeTransporte": "boolean (padrão false)",
  "tipoMaquinarioId": "uuid (obrigatório)"
}
```

**Response 201:** `Servico` criado com `id`, `nome`, `descricao`, `prioridade`, `exigeTransporte`, `tipoMaquinarioId`

**Erros:** `400` campos obrigatórios ausentes · `404` `tipoMaquinarioId` não encontrado

---

### PATCH /obras/:id/servicos/:servicoId — Atualizar serviço

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateServicoDto):** campos parciais de `CreateServicoDto`

**Response 200:** `Servico` atualizado

**Erros:** `404` serviço não encontrado · `409` serviço possui demandas ativas (soft-delete bloqueado)

---

### DELETE /obras/:id/servicos/:servicoId — Excluir serviço (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` serviço possui demandas ativas (`PENDENTE`, `EM_ANDAMENTO`, `AGENDADA`)

---

## 6. Empreiteiras (`/empreiteiras`)

**Rastreio PRD:** `REQ-FUNC-012`

`Empreiteira` é entidade de catálogo global (sem escopo por obra). Para `AdminOperacional`, a listagem retorna as empreiteiras cujos usuários `Empreiteiro` pertencem à obra do header `X-Obra-Id`. Para `SuperAdmin` e `Board`, retorna todas.

---

### GET /empreiteiras — Listar empreiteiras

**Perfis:** `SuperAdmin` (todas), `Board` (todas, read-only), `AdminOperacional` (escopo da obra via `X-Obra-Id`), `UsuarioInternoFGR` (escopo da obra, read-only)

**Query params:** `?search=&page=&limit=`

**Response 200:** lista paginada com `id`, `nome`, `cnpj`, `telefone`, `email`, `responsavel`, `endereco`

---

### POST /empreiteiras — Criar empreiteira

**Perfis:** `SuperAdmin`, `AdminOperacional`

**Request (CreateEmpreiteiraDto):**
```json
{
  "nome": "string (obrigatório)",
  "cnpj": "string | null (opcional; único global quando informado)",
  "telefone": "string | null (opcional)",
  "email": "string | null (opcional)",
  "responsavel": "string | null (opcional)",
  "endereco": "string | null (opcional)"
}
```

**Response 201:** `Empreiteira` criada com `id`, `nome`, `cnpj`

**Erros:** `400` campos obrigatórios ausentes · `409` CNPJ já cadastrado globalmente

---

### GET /empreiteiras/:id — Detalhe de empreiteira

**Perfis:** `SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` (própria empreiteira)

**Response 200:** `Empreiteira` completa com todos os campos

**Erros:** `404` não encontrada · `403` Empreiteiro tentando acessar empreiteira diferente da sua

---

### PATCH /empreiteiras/:id — Atualizar empreiteira

**Perfis:** `SuperAdmin`, `AdminOperacional`

**Request (UpdateEmpreiteiraDto):** campos parciais de `CreateEmpreiteiraDto`

**Response 200:** `Empreiteira` atualizada

**Erros:** `404` não encontrada · `409` CNPJ duplicado

---

### DELETE /empreiteiras/:id — Excluir empreiteira (soft-delete)

**Perfis:** `SuperAdmin`, `AdminOperacional`

**Response 204**

**Erros:** `409` empreiteira possui usuários `Empreiteiro` ativos ou demandas em andamento vinculadas

---

### EmpreiteiraId no payload de criação de usuário Empreiteiro

Ao criar um usuário com `perfil = Empreiteiro`, o payload de criação de usuário (endpoint a ser documentado em TODO item 7) deve incluir obrigatoriamente:

```json
{
  "empreiteiraId": "uuid (obrigatório quando perfil = Empreiteiro)"
}
```

**Validação:** `empreiteiraId` referenciado deve existir (não deletado). Para todos os demais perfis, o campo deve ser omitido ou nulo.

---

## 7. Relatórios e métricas (`/relatorios`)

### GET /relatorios/sla — Métricas de SLA

**Perfis:** `AdminOperacional`, `UsuarioInternoFGR`, `SuperAdmin`, `Board`

**Query params:** `?obraId=&periodo=quinzena|mes&dataInicio=&dataFim=`

**Response 200:**
```json
{
  "periodo": { "inicio": "ISO8601", "fim": "ISO8601" },
  "totalDemandas": "number",
  "atendimentoNoPrazo": "number",
  "taxaAtendimento": "number (0-1)",
  "operadoresAtivos": "number (numerador REQ-MET-002)",
  "operadoresCadastrados": "number (denominador REQ-MET-002 — operadores cadastrados e ativos no sistema para a obra na quinzena)",
  "engajamentoOperacional": "number (0-1)"
}
```

→ Contrato analítico completo de `REQ-MET-002` em [06-definicoes-complementares.md](06-definicoes-complementares.md#contrato-analitico-req-met-002)

---

### GET /relatorios/cancelamentos — Revisão pós-facto

**Perfis:** `AdminOperacional`, `UsuarioInternoFGR`

**Query params:** `?data=YYYY-MM-DD&origem=estouro_sla_fim_expediente`

**Response 200:** lista de demandas canceladas automaticamente no dia indicado, com trilha auditável (`DemandaLog`)

---

## 8. Erros operacionais por domínio

| Código | Domínio | Causa |
|--------|---------|-------|
| `DEM-001` | Demanda | Serviço/maquinário incompatíveis |
| `DEM-002` | Demanda | Localização obrigatória não fornecida |
| `DEM-003` | Demanda | Transição de estado inválida |
| `DEM-004` | Demanda | Justificativa obrigatória ausente |
| `DEM-005` | Demanda | Destino obrigatório ausente para serviço com `exigeTransporte=true` |
| `OPR-001` | Operador | Sem expediente ativo para esta ação |
| `OPR-002` | Operador | Operador fora do setor da demanda (aviso — não bloqueio em alocação manual) |
| `OPR-003` | Operador | Check-in duplicado no mesmo turno |
| `OPR-004` | Operador | Checkout sem expediente ativo |
| `OPR-005` | Operador | Checkout bloqueado — demanda em `EM_ANDAMENTO` ou `PAUSADA` pendente de conclusão |
| `AUTH-001` | Autenticação | Credenciais inválidas (mensagem genérica) |
| `AUTH-002` | Autenticação | Token expirado |
| `AUTH-003` | Autenticação | Perfil sem permissão (RBAC) |
| `AUTH-004` | Autenticação | Rate limit excedido |
| `TEN-001` | Multi-tenant | Recurso não pertence ao tenant da obra |

---

## 9. Rate limiting — resumo

| Endpoint | Limite | Janela | Bloqueio |
|----------|--------|--------|----------|
| `POST /auth/login` | 5 req | 1 min | 15 min por IP/usuário |
| `POST /auth/pin` | 5 req | 1 min | Progressivo: 1/5/15 min |
| `POST /demandas` | 20 req | 1 min | — |
| `POST /demandas/bulk` | 20 req | 1 min | — |

Violações retornam `HTTP 429` com header `Retry-After` (segundos até desbloqueio).

---

-> SPEC: [00-visao-arquitetura.md#decisoes-arquiteturais-adrs](00-visao-arquitetura.md#decisoes-arquiteturais-adrs)
-> SPEC: [03-fila-scoring-estados-sla.md#tabela-de-transicoes-por-perfil](03-fila-scoring-estados-sla.md#tabela-de-transicoes-por-perfil)
-> SPEC: [04-rbac-permissoes.md#matriz-completa-de-permissoes-por-recurso](04-rbac-permissoes.md#matriz-completa-de-permissoes-por-recurso)
-> SPEC: [06-definicoes-complementares.md#contrato-analitico-req-met-002](06-definicoes-complementares.md#contrato-analitico-req-met-002)
-> SPEC: [07-design-ui-logica.md#3-componentes-chave-padroes-angular-20](07-design-ui-logica.md#3-componentes-chave-padroes-angular-20)
