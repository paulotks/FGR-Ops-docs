---
id: 08-api-contratos
title: Contratos de API REST
area: Backend / Integração
---

# Contratos de API REST

**Rastreio PRD:** `REQ-NFR-005`, `REQ-NFR-006`, `REQ-NFR-007`, `REQ-FUNC-001`, `REQ-FUNC-002`, `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-005`, `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-009`, `REQ-FUNC-010`, `REQ-FUNC-011`, `REQ-FUNC-012`, `REQ-FUNC-014`, `REQ-RBAC-001…006`

Este módulo define os contratos de interface REST do `apps/api` (NestJS). Os schemas de request/response são validados via **zod**, partilhados com o frontend `apps/web` (React 19 + Vite) e o futuro `apps/mobile` (React Native/Expo) através dos packages `packages/types` e `packages/schemas` no monorepo (D1, DEC-021, DEC-023).

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
| `400 Bad Request` | Payload inválido (falha de validação Zod) |
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
  "operadorAlocadoId": "uuid | null (apenas AdminOperacional / SuperAdmin)"
}
```

> `setorOperacionalId` é derivado automaticamente pelo backend a partir de `quadraId`/`loteId`/`localExternoId` (DEC-005).

**Response 201:**
```json
{
  "id": "uuid",
  "status": "PENDENTE | AGENDADA | AGUARDANDO_APROVACAO",
  "score": "number",
  "setorOperacionalId": "uuid",
  "criadoEm": "ISO8601"
}
```

> `status = AGUARDANDO_APROVACAO` quando criador é `UsuarioInternoFGR` com `urgencia = AGENDADA` (DEC-027). `status = AGENDADA` quando criador é `AdminOperacional` ou `SuperAdmin` com `urgencia = AGENDADA`.

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

**Response 200:** lista paginada de demandas com campos principais (id, status, score, localTipo, criadoEm, empreiteiro, operador, `rolloverDe`)

> O campo `rolloverDe: date | null` (DEC-025) é incluído em todas as respostas que retornam demandas (listagem, detalhe e kanban). Indica a data de origem do rollover — `null` para demandas do dia corrente; data ISO 8601 (dia) para demandas redistribuídas de dia anterior.

---

### GET /demandas/:id — Detalhe de demanda

**Response 200:** demanda completa incluindo `DemandaLog[]` e campo `rolloverDe: date | null` (DEC-025)

**Erros:** `404` não encontrada no tenant

---

### PATCH /demandas/:id/estado — Transição de estado

**Perfis e transições autorizadas:** conforme tabela em [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md#tabela-de-transicoes-por-perfil)

**Request (TransicaoEstadoDto):**
```json
{
  "acao": "iniciar | concluir | cancelar | pausar | retomar | devolver | antecipar",
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

## 3b. Ciclo de aceite de demandas agendadas (`/demandas/:id/...`)

**Rastreio PRD:** `REQ-FUNC-006`, `REQ-FUNC-014`

Endpoints do ciclo de vida de demandas com `urgencia = AGENDADA`, cobrindo aceite/recusa pelo operador, aprovação/rejeição pelo admin e solicitação de cancelamento (DEC-026, DEC-027, DEC-028, DEC-029).

### Enum `EstadoDemanda` — valores relevantes a esta seção

| Estado | Descrição |
|--------|-----------|
| `AGENDADA` | Demanda agendada visível para operadores com TipoMaquinario compatível; aguarda aceite |
| `AGUARDANDO_APROVACAO` | Criada por `UsuarioInternoFGR`; aguarda aprovação de AdminOp/SuperAdmin antes de ir a `AGENDADA` (DEC-027) |
| `NAO_EXECUTADA` | Estado terminal — demanda agendada expirou sem aceite (T-1h antes da `dataAgendada`) (DEC-028) |
| `PENDENTE` | Estado após aceite do operador; entra na fila normal |
| `CANCELADA` | Terminal — rejeição pelo admin ou cancelamento aprovado |

---

### POST /demandas/:id/aceitar-agendamento

Operador aceita demanda agendada. Requer TipoMaquinario compatível e slot livre (janela configurável por obra — DEC-026).

**Rastreio PRD:** `REQ-FUNC-006`

**Perfil:** `Operador`

**Request:**
```json
{
  "operadorId": "uuid"
}
```

**Validações:**
- Demanda deve estar em estado `AGENDADA`
- Operador deve ter TipoMaquinario compatível com o serviço da demanda
- Operador não pode ter outra demanda aceita no mesmo slot horário (janela de conflito configurável por obra)

**Response 200:**
```json
{
  "demandaId": "uuid",
  "novoEstado": "PENDENTE",
  "aceiteEm": "ISO8601"
}
```

**Erros:** `400` slot em conflito (`{ code: "SLOT_CONFLITO" }`) · `409` demanda já aceita por outro operador · `422` demanda não está em `AGENDADA` · `422` TipoMaquinario incompatível

---

### POST /demandas/:id/recusar-agendamento

Operador recusa demanda agendada. Demanda permanece em `AGENDADA` para outros operadores com TipoMaquinario compatível.

**Rastreio PRD:** `REQ-FUNC-006`

**Perfil:** `Operador`

**Request:**
```json
{
  "operadorId": "uuid",
  "motivo": "string | null (opcional)"
}
```

**Validações:** Demanda deve estar em `AGENDADA`

**Response 200:**
```json
{
  "demandaId": "uuid",
  "logStatus": "RECUSADA"
}
```

**Erros:** `422` demanda não está em `AGENDADA`

---

### POST /demandas/:id/solicitar-cancelamento

Operador solicita cancelamento de demanda agendada que aceitou previamente. Motivo obrigatório. AdminOp/SuperAdmin decide no painel (DEC-029).

**Rastreio PRD:** `REQ-FUNC-006`

**Perfil:** `Operador`

**Request:**
```json
{
  "operadorId": "uuid",
  "motivo": "string (obrigatório)"
}
```

**Validações:** Demanda deve ter sido aceita pelo operador solicitante (operadorId deve coincidir com `aceiteOperadorId` da demanda)

**Response 201:**
```json
{
  "solicitacaoId": "uuid",
  "estado": "PENDENTE"
}
```

**Erros:** `400` motivo ausente · `403` operador não é o aceitante da demanda · `409` solicitação de cancelamento já existe para esta demanda

---

### POST /demandas/:id/aprovar-agendamento

Admin aprova agendamento criado por `UsuarioInternoFGR`. Demanda transita de `AGUARDANDO_APROVACAO` para `AGENDADA` e fica visível para aceite de operadores (DEC-027).

**Rastreio PRD:** `REQ-FUNC-006`

**Perfil:** `AdminOperacional`, `SuperAdmin`

**Request:**
```json
{
  "adminId": "uuid"
}
```

**Validações:** Demanda deve estar em `AGUARDANDO_APROVACAO`

**Response 200:**
```json
{
  "demandaId": "uuid",
  "novoEstado": "AGENDADA"
}
```

**Erros:** `422` demanda não está em `AGUARDANDO_APROVACAO` · `403` perfil sem autorização

---

### POST /demandas/:id/rejeitar-agendamento

Admin rejeita agendamento de `UsuarioInternoFGR`. Demanda transita de `AGUARDANDO_APROVACAO` para `CANCELADA`. Motivo obrigatório (DEC-027).

**Rastreio PRD:** `REQ-FUNC-006`

**Perfil:** `AdminOperacional`, `SuperAdmin`

**Request:**
```json
{
  "adminId": "uuid",
  "motivo": "string (obrigatório)"
}
```

**Validações:** Demanda deve estar em `AGUARDANDO_APROVACAO`

**Response 200:**
```json
{
  "demandaId": "uuid",
  "novoEstado": "CANCELADA"
}
```

**Erros:** `400` motivo ausente · `422` demanda não está em `AGUARDANDO_APROVACAO` · `403` perfil sem autorização

---

### POST /demandas/:id/cancelamento/:solicitacaoId/aprovar

Admin aprova solicitação de cancelamento do operador. Demanda transita para `CANCELADA` (DEC-029).

**Rastreio PRD:** `REQ-FUNC-006`

**Perfil:** `AdminOperacional`, `SuperAdmin`

**Request:**
```json
{
  "adminId": "uuid"
}
```

**Response 200:**
```json
{
  "demandaId": "uuid",
  "novoEstado": "CANCELADA",
  "solicitacaoEstado": "APROVADA"
}
```

**Erros:** `404` solicitação não encontrada · `409` solicitação já decidida · `403` perfil sem autorização

---

### POST /demandas/:id/cancelamento/:solicitacaoId/rejeitar

Admin rejeita solicitação de cancelamento do operador. Demanda permanece no estado vigente (DEC-029).

**Rastreio PRD:** `REQ-FUNC-006`

**Perfil:** `AdminOperacional`, `SuperAdmin`

**Request:**
```json
{
  "adminId": "uuid",
  "motivo": "string (obrigatório)"
}
```

**Response 200:**
```json
{
  "solicitacaoId": "uuid",
  "solicitacaoEstado": "REJEITADA"
}
```

**Erros:** `400` motivo ausente · `404` solicitação não encontrada · `409` solicitação já decidida · `403` perfil sem autorização

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

**Rastreio PRD:** `REQ-FUNC-004`, `REQ-FUNC-014`

**Perfil:** `Operador`

**Request:**
```json
{
  "ajudanteId": "uuid | null"
}
```

> Campo `ajudanteId` opcional — usado apenas para registrar o ajudante ativo no encerramento, se diferente do informado no check-in.

**Comportamento atualizado (DEC-025):** O checkout não é bloqueado por demandas em `EM_ANDAMENTO` ou `PAUSADA`. Em vez disso, todas as demandas ativas do operador são automaticamente devolvidas ao sistema:
- Ação: `devolver_fim_expediente` (ator: SISTEMA)
- Transição: `EM_ANDAMENTO / PAUSADA → RETORNADA → PENDENTE`
- Log: `DemandaLog` registrado com justificativa automática para cada demanda devolvida

**Response 200:**
```json
{
  "expedienteId": "uuid",
  "fimEm": "ISO8601",
  "totalDemandas": "number",
  "devolvidasIds": ["uuid"]
}
```

> `devolvidasIds` lista as demandas devolvidas automaticamente no checkout. Array vazio quando o operador não possuía demandas ativas.

**Erros:** `404 OPR-004` sem expediente ativo

---

### POST /operadores/:id/ajudante — Trocar ajudante durante expediente

**Rastreio PRD:** `REQ-FUNC-004`

**Perfil:** `Operador` (próprio expediente), `AdminOperacional`, `SuperAdmin`

> Permite substituir o ajudante ativo durante o turno sem necessidade de checkout/checkin. Encerra o `TurnoAjudante` vigente e cria um novo registro com o ajudante informado.

**Request (TrocarAjudanteDto):**
```json
{
  "ajudanteId": "uuid (obrigatório)"
}
```

**Response 200:**
```json
{
  "registroExpedienteId": "uuid",
  "turnoAjudanteAnteriorId": "uuid | null",
  "turnoAjudanteNovoId": "uuid",
  "ajudanteId": "uuid",
  "inicioEm": "ISO8601"
}
```

**Erros:** `404 OPR-001` sem expediente ativo · `404` ajudante não encontrado na obra · `409` ajudante já é o ajudante ativo do turno · `422` ajudante em turno ativo com outro operador

---

## 4b. Usuários (`/usuarios`)

**Rastreio PRD:** `REQ-RBAC-001…006`, `REQ-FUNC-012`

### GET /usuarios — Listar usuários

**Perfis:** `SuperAdmin` (cross-tenant), `Board` (cross-tenant, read-only), `AdminOperacional` (escopo da obra), `UsuarioInternoFGR` (escopo da obra, read-only)

**Query params:** `?perfil=&obraId=&search=&page=&limit=`

**Response 200:** lista paginada de `User` com `id`, `nome`, `email`, `perfil`, `obraId`, `empreiteiraId`, `ativo`

---

### POST /usuarios — Criar usuário

**Perfis:** `SuperAdmin`, `AdminOperacional`

**Request (CreateUsuarioDto):**
```json
{
  "nome": "string (obrigatório)",
  "email": "string | null (obrigatório para perfis administrativos; opcional para Operador/Empreiteiro)",
  "perfil": "SuperAdmin | AdminOperacional | UsuarioInternoFGR | Empreiteiro | Operador (obrigatório)",
  "obraId": "uuid (obrigatório para perfis tenant-scoped)",
  "empreiteiraId": "uuid | null (obrigatório quando perfil = Empreiteiro; nulo para demais perfis)",
  "pin": "string (≥6 dígitos, obrigatório para perfis Operador e Empreiteiro)",
  "password": "string (≥8 chars, 4 classes, obrigatório para perfis administrativos)",
  "tiposMaquinarioIds": ["uuid (obrigatório quando perfil = Operador — lista de TipoMaquinario autorizados)"]
}
```

> O `AdminOperacional` só pode criar usuários com perfil hierárquico inferior ou igual dentro da mesma obra (condição [1] do RBAC).

**Response 201:**
```json
{
  "id": "uuid",
  "nome": "string",
  "email": "string | null",
  "perfil": "string",
  "obraId": "uuid | null",
  "empreiteiraId": "uuid | null"
}
```

**Erros:** `400` campos obrigatórios ausentes · `404` `empreiteiraId` ou `obraId` não encontrado · `409` email duplicado · `422` `empreiteiraId` informado para perfil diferente de Empreiteiro · `422` `tiposMaquinarioIds` ausente para perfil Operador

---

### GET /usuarios/:id — Detalhe de usuário

**Perfis:** `SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`

**Response 200:** `User` completo com `id`, `nome`, `email`, `perfil`, `obraId`, `empreiteiraId`, `empreiteira` (expandido), `tiposMaquinario[]` (quando Operador)

**Erros:** `404` não encontrado · `403` tentativa de acessar usuário de outra obra (para perfis tenant-scoped)

---

### PATCH /usuarios/:id — Atualizar usuário

**Perfis:** `SuperAdmin`, `AdminOperacional` (condição [1])

**Request (UpdateUsuarioDto):** campos parciais de `CreateUsuarioDto` (exceto `perfil`, que é imutável)

**Response 200:** `User` atualizado

**Erros:** `404` não encontrado · `409` email duplicado · `403` tentativa de alterar usuário de perfil superior

---

### DELETE /usuarios/:id — Excluir usuário (soft-delete)

**Perfis:** `SuperAdmin`, `AdminOperacional` (condição [1])

**Response 204**

**Erros:** `404` não encontrado · `403` tentativa de excluir usuário de perfil superior · `409` usuário possui expedientes ou demandas ativas

---

## 5. Obras e recursos espaciais (`/obras`)

### GET /obras/:id — Detalhe de obra

**Response 200:** obra com `setoresOperacionais[]`, `expedienteInicio`, `expedienteFim`

---

### GET /obras/:id/setores — Listar setores operacionais

**Perfis:** todos (leitura de contexto)

**Response 200:** lista de `SetorOperacional` com `id`, `nome`, `quadras[]` e `locaisExternos[]`

---

### POST /obras/:id/setores — Criar setor operacional

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateSetorOperacionalDto):**
```json
{
  "nome": "string (obrigatório)"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "nome": "string",
  "obraId": "uuid"
}
```

**Erros:** `400` campos obrigatórios ausentes · `409` nome duplicado na mesma obra

---

### PATCH /obras/:id/setores/:setorId — Atualizar setor operacional

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateSetorOperacionalDto):** campos parciais de `CreateSetorOperacionalDto`

**Response 200:** `SetorOperacional` atualizado

**Erros:** `404` setor não encontrado · `409` nome duplicado

---

### DELETE /obras/:id/setores/:setorId — Excluir setor operacional (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` setor possui quadras ou locais externos ativos vinculados

---

### GET /obras/:id/quadras — Listar quadras

**Perfis:** todos (leitura de contexto)

**Query params:** `?setorId=&ruaId=&page=&limit=`

**Response 200:** lista paginada de `Quadra` com `id`, `codigo`, `setorOperacionalId`, `ruaId`, `lotes[]`

---

### POST /obras/:id/quadras — Criar quadra

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateQuadraDto):**
```json
{
  "codigo": "string (obrigatório)",
  "setorOperacionalId": "uuid (obrigatório)",
  "ruaId": "uuid | null (opcional)"
}
```

> `setorOperacionalId` deve referenciar um `SetorOperacional` da mesma obra (DEC-015).

**Response 201:**
```json
{
  "id": "uuid",
  "codigo": "string",
  "obraId": "uuid",
  "setorOperacionalId": "uuid",
  "ruaId": "uuid | null"
}
```

**Erros:** `400` campos obrigatórios ausentes · `404` `setorOperacionalId` ou `ruaId` não encontrado na obra · `409` código duplicado na mesma obra

---

### PATCH /obras/:id/quadras/:quadraId — Atualizar quadra

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateQuadraDto):** campos parciais de `CreateQuadraDto`

**Response 200:** `Quadra` atualizada

**Erros:** `404` quadra não encontrada · `409` código duplicado · `422` `setorOperacionalId` de obra diferente

---

### DELETE /obras/:id/quadras/:quadraId — Excluir quadra (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` quadra possui lotes ativos vinculados ou demandas ativas

---

### GET /obras/:id/quadras/:quadraId/lotes — Listar lotes

**Perfis:** todos (leitura de contexto)

**Query params:** `?page=&limit=`

**Response 200:** lista paginada de `Lote` com `id`, `codigo`, `quadraId`

---

### POST /obras/:id/quadras/:quadraId/lotes — Criar lote

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateLoteDto):**
```json
{
  "codigo": "string (obrigatório)"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "codigo": "string",
  "quadraId": "uuid"
}
```

**Erros:** `400` campos obrigatórios ausentes · `404` `quadraId` não encontrado na obra · `409` código duplicado na mesma quadra

---

### PATCH /obras/:id/quadras/:quadraId/lotes/:loteId — Atualizar lote

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateLoteDto):** campos parciais de `CreateLoteDto`

**Response 200:** `Lote` atualizado

**Erros:** `404` lote não encontrado · `409` código duplicado

---

### DELETE /obras/:id/quadras/:quadraId/lotes/:loteId — Excluir lote (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` lote possui adjacências ativas ou demandas ativas

---

### GET /obras/:id/quadras/:quadraId/lotes/:loteId/adjacencias — Listar adjacências do lote

**Perfis:** todos (leitura de contexto)

**Response 200:** lista de `LoteAdjacencia` com `loteOrigemId`, `loteDestinoId` e dados descritivos do lote destino (`codigo`, `quadraCodigo`)

---

### POST /obras/:id/quadras/:quadraId/lotes/:loteId/adjacencias — Criar adjacência

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateLoteAdjacenciaDto):**
```json
{
  "loteDestinoId": "uuid (obrigatório)"
}
```

> A relação é bidirecional: ao criar `A → B`, o backend cria automaticamente `B → A`. A validação garante que os dois lotes pertencem à mesma obra.

**Response 201:**
```json
{
  "loteOrigemId": "uuid",
  "loteDestinoId": "uuid"
}
```

**Erros:** `400` `loteDestinoId` ausente · `404` lote destino não encontrado na obra · `409` adjacência já existente · `422` lote destino é o próprio lote origem

---

### DELETE /obras/:id/quadras/:quadraId/lotes/:loteId/adjacencias/:loteDestinoId — Remover adjacência

**Perfis:** `AdminOperacional`, `SuperAdmin`

> Remove a relação bidirecional: exclui tanto `A → B` quanto `B → A`.

**Response 204**

**Erros:** `404` adjacência não encontrada

---

### GET /obras/:id/locais-externos — Listar locais externos

**Perfis:** todos (leitura de contexto)

**Query params:** `?setorId=&tipo=&page=&limit=`

**Response 200:** lista paginada de `LocalExterno` com `id`, `nome`, `tipo`, `setorOperacionalId`

---

### POST /obras/:id/locais-externos — Criar local externo

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateLocalExternoDto):**
```json
{
  "nome": "string (obrigatório)",
  "tipo": "string (obrigatório — ex.: PORTARIA, PULMAO, GARAGEM, OUTRO)",
  "setorOperacionalId": "uuid (obrigatório)"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "nome": "string",
  "tipo": "string",
  "setorOperacionalId": "uuid",
  "obraId": "uuid"
}
```

**Erros:** `400` campos obrigatórios ausentes · `404` `setorOperacionalId` não encontrado na obra · `409` nome duplicado no mesmo setor

---

### PATCH /obras/:id/locais-externos/:localExternoId — Atualizar local externo

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateLocalExternoDto):** campos parciais de `CreateLocalExternoDto`

**Response 200:** `LocalExterno` atualizado

**Erros:** `404` local externo não encontrado · `409` nome duplicado · `422` `setorOperacionalId` de obra diferente

---

### DELETE /obras/:id/locais-externos/:localExternoId — Excluir local externo (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` local externo possui demandas ativas

---

### GET /obras/:id/ajudantes — Listar ajudantes

**Perfis:** `AdminOperacional`, `UsuarioInternoFGR`, `SuperAdmin`, `Operador` (leitura de contexto)

**Query params:** `?search=&page=&limit=`

**Response 200:** lista paginada de `Ajudante` com `id`, `nome`, `obraId`

---

### POST /obras/:id/ajudantes — Criar ajudante

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateAjudanteDto):**
```json
{
  "nome": "string (obrigatório)"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "nome": "string",
  "obraId": "uuid"
}
```

**Erros:** `400` campos obrigatórios ausentes · `409` nome duplicado na mesma obra

---

### PATCH /obras/:id/ajudantes/:ajudanteId — Atualizar ajudante

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateAjudanteDto):** campos parciais de `CreateAjudanteDto`

**Response 200:** `Ajudante` atualizado

**Erros:** `404` ajudante não encontrado

---

### DELETE /obras/:id/ajudantes/:ajudanteId — Excluir ajudante (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` ajudante possui turnos ativos vinculados

---

### GET /obras/:id/materiais — Listar materiais

**Perfis:** todos (leitura de contexto)

**Query params:** `?search=&risco=&page=&limit=`

**Response 200:** lista paginada de `Material` com `id`, `nome`, `risco`

---

### POST /obras/:id/materiais — Criar material

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateMaterialDto):**
```json
{
  "nome": "string (obrigatório)",
  "risco": "string | null (opcional — classificação de risco, ex.: BAIXO, MEDIO, ALTO)"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "nome": "string",
  "risco": "string | null"
}
```

**Erros:** `400` campos obrigatórios ausentes · `409` nome duplicado na mesma obra

---

### PATCH /obras/:id/materiais/:materialId — Atualizar material

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateMaterialDto):** campos parciais de `CreateMaterialDto`

**Response 200:** `Material` atualizado

**Erros:** `404` material não encontrado · `409` nome duplicado

---

### DELETE /obras/:id/materiais/:materialId — Excluir material (soft-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409` material possui demandas ativas vinculadas

---

### GET /obras/:id/fila — Fila global da obra (kanban administrativo)

**Rastreio PRD:** `REQ-FUNC-001`, `REQ-FUNC-002`, `REQ-FUNC-008`

**Perfis:** `AdminOperacional`, `UsuarioInternoFGR`, `SuperAdmin`

> Corresponde ao kanban em tempo real descrito em [07-design-ui-logica.md](07-design-ui-logica.md). Retorna todas as demandas ativas da obra com posição de fila, score e status de SLA, permitindo supervisão e filtragem cruzada.

**Query params:** `?status=&setorId=&operadorId=&prioridade=&page=&limit=`

| Param | Tipo | Descrição |
|-------|------|-----------|
| `status` | `string` | Filtrar por estado (`PENDENTE`, `EM_ANDAMENTO`, `PAUSADA`, `AGENDADA`, `AGUARDANDO_APROVACAO`, `RETORNADA`, `CONCLUIDA`, `CANCELADA`, `NAO_EXECUTADA`) |
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
      "status": "PENDENTE | EM_ANDAMENTO | PAUSADA | AGENDADA | AGUARDANDO_APROVACAO | RETORNADA | CONCLUIDA | CANCELADA | NAO_EXECUTADA",
      "rolloverDe": "date | null (DEC-025)",
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
  "pesoAdjacencia": "number (0–100) | null",
  "pesoServico": "number (0–100) | null",
  "pesoMaterial": "number (0–100) | null"
}
```

> Campos omitidos mantêm o valor atual. Cada peso aceita valores no intervalo `[0, 100]`, sem obrigação de soma total. Padrão do sistema: `W_adj = 50`, `W_srv = 30`, `W_mat = 20` (conforme [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md)). (DEC-024)

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

**Erros:** `400` peso fora do intervalo [0, 100] · `404` obra não encontrada · `422` `expedienteInicio` igual ou posterior a `expedienteFim`

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

Ao criar um usuário com `perfil = Empreiteiro`, o payload de `POST /usuarios` (seção 4b) deve incluir obrigatoriamente:

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
| `OPR-005` | Operador | ~~Checkout bloqueado~~ — **Supersedido por DEC-025**: demandas em `EM_ANDAMENTO`/`PAUSADA` são devolvidas automaticamente no checkout (`devolver_fim_expediente`, ator SISTEMA); código reservado para referência histórica |
| `OPR-006` | Operador | Ajudante já é o ajudante ativo do turno |
| `OPR-007` | Operador | Ajudante em turno ativo com outro operador |
| `REC-001` | Recurso espacial | Nome/código duplicado na mesma obra |
| `REC-002` | Recurso espacial | Recurso possui dependências ativas (não pode ser excluído) |
| `REC-003` | Recurso espacial | Adjacência já existente |
| `REC-004` | Recurso espacial | Lote destino é o próprio lote origem |
| `USR-001` | Usuário | Email duplicado |
| `USR-002` | Usuário | Perfil hierárquico superior ao do solicitante |
| `USR-003` | Usuário | `empreiteiraId` inválido para o perfil informado |
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

## 10. Eventos WebSocket (`/ws`)

**Rastreio PRD:** `REQ-FUNC-006`, `REQ-FUNC-014`

O canal WebSocket (`/ws`) é gerenciado pelo NestJS com proxy via IIS ARR (DEC-022). Clientes autenticados recebem eventos de domínio em tempo real filtrados por perfil e `obraId` (D4). Eventos WebSocket são unidirecionais — servidor → cliente.

### Convenções gerais de eventos

| Campo | Valor |
|-------|-------|
| Protocolo | WebSocket com upgrade preservado via IIS ARR (DEC-022) |
| Autenticação | Token JWT enviado no handshake (`Authorization: Bearer <token>`) |
| Envelope | `{ "tipo": "string", ...payload }` |
| Scope | Filtrado por `obraId` (D4); `SuperAdmin`/`Board` recebem cross-tenant (D5) |

---

### Evento: AGENDADA_DISPONIVEL (DEC-026)

**Rastreio PRD:** `REQ-FUNC-006`

Emitido quando uma demanda agendada fica disponível para aceite. Inclui demandas que transitam para `AGENDADA` (aprovação de AdminOp para agendamentos de `UsuarioInternoFGR` — DEC-027) e demandas recém-criadas com `urgencia = AGENDADA` por AdminOp/SuperAdmin.

**Canal:** Todos os operadores conectados com `TipoMaquinario` compatível com o serviço da demanda (broadcast por TipoMaquinario — sem filtro de setor, DEC-026)

**Payload:**
```json
{
  "tipo": "AGENDADA_DISPONIVEL",
  "demandaId": "uuid",
  "dataAgendada": "ISO8601",
  "tipoMaquinarioId": "uuid",
  "tipoMaquinarioNome": "string",
  "servicoNome": "string",
  "expiracaoAceiteEm": "ISO8601"
}
```

> `expiracaoAceiteEm` corresponde a T-1h antes da `dataAgendada`. Após esse instante, a demanda transita automaticamente para `NAO_EXECUTADA` (DEC-028).

---

-> SPEC: [00-visao-arquitetura.md#decisoes-arquiteturais-adrs](00-visao-arquitetura.md#decisoes-arquiteturais-adrs)
-> SPEC: [03-fila-scoring-estados-sla.md#tabela-de-transicoes-por-perfil](03-fila-scoring-estados-sla.md#tabela-de-transicoes-por-perfil)
-> SPEC: [04-rbac-permissoes.md#matriz-completa-de-permissoes-por-recurso](04-rbac-permissoes.md#matriz-completa-de-permissoes-por-recurso)
-> SPEC: [06-definicoes-complementares.md#contrato-analitico-req-met-002](06-definicoes-complementares.md#contrato-analitico-req-met-002)
-> SPEC: [07-design-ui-logica.md#3-componentes-chave-padroes-react](07-design-ui-logica.md#3-componentes-chave-padroes-react)
