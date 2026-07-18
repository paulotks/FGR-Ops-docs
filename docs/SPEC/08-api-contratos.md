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
| Base URL | `/api/v1` — **exceção:** `GET /health` fica **fora** do prefixo (probe de infra/IIS; exclusão via `setGlobalPrefix('api/v1', { exclude: ['health'] })`) |
| Autenticação | `Authorization: Bearer <access_token>` (JWT) |
| Content-Type | `application/json` |
| Erros | Objeto `{ statusCode, message, error?, details? }` |
| Tenant scope | Perfis não-bypass: o `obraId` efetivo vem da **claim do JWT** (D4); sem `obraId` no contexto → `403 RBAC-003`. Perfis bypass `SuperAdmin`/`Board` (D5): sem header, operam em **visão panóptica** (`obraId` nulo, sem filtro de tenant); header **opcional** `X-Tenant-Obra-Id` (UUID) define `obraIdAlvo` de filtro pontual cross-tenant — validado como UUID e contra `Obra` existente (desconhecida → `400 RBAC-004`). Para os demais perfis o **valor** do header é ignorado (não substitui a claim); nota: a validação de formato é prévia ao branch de perfil, então header malformado → `400` para qualquer perfil autenticado |
| Paginação | Query params `?page=1&limit=20`; resposta inclui `{ data[], total, page, limit }`. Aplica-se aos endpoints unbounded que declaram `?page=&limit=`; coleções bounded (catálogos) respondem array puro — ver o contrato por endpoint |
| Timestamps | ISO 8601 **UTC** (sufixo `Z`) no wire — serialização nativa `Date.toISOString()`, sem transform de timezone no backend; apresentação em `America/Sao_Paulo` é responsabilidade do frontend |

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

**Rate limit:** 30 req/min por IP (anti-DoS de rota, DEC 2026-05-29 — IP compartilhado de canteiro não trava operadores no início do turno); brute-force por usuário coberto pelo lockout progressivo 1/5/15 min (`REQ-NFR-007`, D6)

**Request:**
```json
{
  "usuario": "string (CPF do usuário de campo — 11 dígitos, com ou sem máscara; normalizado por stripNonDigits)",
  "pin": "string (≥6 dígitos numéricos)"
}
```

> **Identificador de campo = CPF (DEC-042).** O campo `usuario` é o **CPF** do usuário de campo (`OPERADOR`/`EMPREITEIRO`); o handler resolve a identidade por `findByCpf` — **não** por `findByEmail`, que permanece exclusivo do `POST /auth/login` administrativo. O schema de login (`pinSchema.usuario`) é `z.string().min(1)`: um CPF malformado **não** é rejeitado na validação — cai no resolver e retorna `401` genérico + lockout + audit (CPF mascarado), preservando **DEC-004** (erro não-enumerável). A chave de lockout progressivo normaliza o CPF, de modo que variantes de máscara não burlam o bloqueio per-usuário.

**Response 200:**
```json
{
  "accessToken": "string (JWT, 15 min)",
  "refreshToken": "string (JWT, 12 h — campo)",
  "perfil": "Empreiteiro | Operador",
  "obraId": "uuid"
}
```

**Erros específicos:** `401` credenciais inválidas (mensagem genérica, não enumerável — inclui CPF inexistente, malformado ou PIN incorreto) · `429` lockout progressivo

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

> **MVP-15jul (Slice 9, T9.4 — REQ-FUNC-005) — contrato estruturado ativo:** o `POST /demandas`
> usa o DTO **estruturado** `criarDemandaSchema` (catálogos Serviço + Espacial — Slices 8/9).
> O free-text da Slice 3 (`{ descricao: string (obrigatório), material?: string }`) e o
> free-text+serviço da Slice 8 (T8.4: `{ servicoId, descricao, material? }`) foram
> **supersedidos por este contrato estruturado** (gate de saída da Slice 9: "sem texto livre temporário").
> O `obraId` efetivo vem do `TenantContext` (claim JWT para não-bypass; header
> `X-Tenant-Obra-Id` para `SuperAdmin`); `SuperAdmin` **sem** o header → `400 { error: 'RBAC-003' }`.
>
> **Regras de validação (camadas):** (1) **Zod** valida só o shape puro — pareamento
> `localTipo↔FK` de local obrigatória + destino `both-or-neither`; (2) **use-case** valida
> cross-entity — FK existe na obra (`404 DEM-009`), `exigeTransporte→destino/transporteInterno`
> (`422 DEM-005`, bidirecional), setor derivado de local (DEC-005); (3) **aggregate**
> `Demanda.criar` mantém a invariante de material (`DEM-007/008`).
> `servicoId` é `z.string().trim().min(1)` (NÃO `.uuid()`) — IDs NVarChar(36).
> `DemandaResumoDto` expõe leitura estruturada rasa desde 2026-07-14 (design
> card-demanda-rico-campo): `servicoNome`, `prioridade`, `localResumo`, `solicitanteNome` —
> todos nullable (demanda legada free-text). `servicoId` (FK) segue write-only; SLA NÃO
> trafega (derivado no FE de `prioridade`+`criadoEm`, SPEC/03). Nota de assimetria: campo
> de request `descricaoAdicional` mapeia para a coluna `descricao` (response usa `descricao`).
>
> **Regra condicional de `material` (server-owned, inalterada desde T8.4):** o backend faz
> lookup de `Servico.categoria` pelo `servicoId` e impõe — `categoria = MOVIMENTACAO` ⇒
> `material` **obrigatório** (senão `400 DEM-007`); `categoria = OUTRO` ⇒ `material`
> **rejeitado** (`400 DEM-008`). `servicoId` inexistente ⇒ `404 DEM-006`. Sem migration
> (colunas `servicoId`/`localTipo`/`quadraId`/`loteId`/`localExternoId`/`setorOperacionalId`/
> `transporteInterno`/`destinoQuadraId`/`destinoLoteId` pré-existiam nullable).
>
> **`tipoMaquinarioId` obrigatório (Slice 9, REQ-FUNC-003/REQ-FUNC-002).** Desde o
> N:M Serviço⇄TipoMaquinario, o Empreiteiro escolhe explicitamente o tipo de
> maquinário no form (filtro bidirecional serviço↔tipo). O use-case valida que
> `tipoMaquinarioId` ∈ conjunto de tipos vinculados ao `servicoId` (join
> `ServicoTipoMaquinario`) — incompatível ⇒ `422 DEM-010`. Persistido em
> `Demanda.tipoMaquinarioId` (coluna nullable — legado pré-Slice-9 fica `null`;
> obrigatória apenas na borda Zod para criações novas). Alimenta o hard-filter de
> compatibilidade do auto-allocator (join `OperadorTipoMaquinario`); demandas
> legadas com `tipoMaquinarioId = null` seguem o comportamento anterior do
> allocator (sem filtro de tipo).
>
> **`GET /demandas/minhas`** (MVP, REQ-FUNC-005) — Perfil `Empreiteiro`. Lista paginada
> `{ data, total, page, limit }` (`?page=&limit=`, default `page=1`/`limit=20`, teto 100)
> das demandas criadas pelo usuário autenticado (`criadoPorId`), filtradas por `obraId`
> e `deletadoEm: null`, ordenadas por `criadoEm desc`.

**Rate limit criação:** 20 req/min por usuário autenticado (D3, `REQ-NFR-006`)

### POST /demandas — Criar demanda

> **ATIVO — MVP-15jul, Slice 9 T9.4 (REQ-FUNC-005).** Contrato estruturado que substitui o
> free-text da Slice 3 e o free-text+serviço da Slice 8 (T8.4). Schema: `criarDemandaSchema`
> em `packages/schemas/src/machinery-link/demanda/create-demanda.schema.ts`.

**Perfis:** `Empreiteiro`, `TowerOperator`, `AdminOperacional`, `UsuarioInternoFGR`, `SuperAdmin`

**Request (CriarDemandaInput — `criarDemandaSchema`):**
```json
{
  "servicoId": "string (obrigatório — NVarChar(36), NÃO uuid-validado pelo Zod)",
  "tipoMaquinarioId": "string (obrigatório — Slice 9, REQ-FUNC-003/REQ-FUNC-002; deve pertencer ao conjunto de tipos vinculados ao serviço)",
  "localTipo": "QUADRA_LOTE | LOCAL_EXTERNO (obrigatório)",
  "quadraId": "string (obrigatório quando localTipo = QUADRA_LOTE)",
  "loteId": "string (obrigatório quando localTipo = QUADRA_LOTE)",
  "localExternoId": "string (obrigatório quando localTipo = LOCAL_EXTERNO)",
  "transporteInterno": "boolean (opcional — indica que origem = destino; disponível apenas se exigeTransporte=true)",
  "destinoQuadraId": "string (opcional — obrigatório junto de destinoLoteId quando exigeTransporte=true e transporteInterno ausente/false)",
  "destinoLoteId": "string (opcional — obrigatório junto de destinoQuadraId; both-or-neither validado pelo Zod)",
  "material": "string (opcional — texto livre; coluna materialTexto; obrigatório para categoria=MOVIMENTACAO, rejeitado para OUTRO)",
  "descricaoAdicional": "string (opcional — campo de request; persiste na coluna descricao; response retorna como 'descricao')",
  "operadorId": "string (opcional — pré-alocação manual; SOMENTE TowerOperator/AdminOperacional/SuperAdmin, amendment 2026-07-15)"
}
```

> **Campos removidos do contrato anterior:** `maquinarioId`, `materialId`, `urgencia`, `dataAgendada`, `operadorAlocadoId` — fora do escopo MVP-15jul. (`operadorId` reintroduzido parcialmente em 2026-07-15, gestão-only — ver amendment abaixo.)
>
> `setorOperacionalId` é derivado automaticamente pelo backend a partir de `quadraId`/`loteId`/`localExternoId` (DEC-005) — não trafega no request.
>
> **Assimetria request/response:** campo de request `descricaoAdicional` → coluna `descricao` → response `descricao`. Ambos mapeiam a mesma coluna; o nome de request é descritivo (adicional ao serviço), o de response é o campo canônico do aggregate.

> **Amendment 2026-07-15 — pré-alocação manual pela gestão (REQ-FUNC-005, design
> `docs/superpowers/specs/2026-07-15-criar-demanda-gestao-design.md`):** o body aceita
> `operadorId?` (Operador.id) SOMENTE para `TowerOperator`, `AdminOperacional` e `SuperAdmin`
> (`DEMANDA_FILA_WRITE_PERFIS` — mesma constante do `POST /demandas/:id/alocar`). Outro perfil
> enviando o campo → `403 {error: 'RBAC-001'}`. Operador inexistente na obra do contexto →
> `404 {error: 'TEN-001'}`, validado ANTES de persistir. Com `operadorId` válido: a demanda
> nasce `PENDENTE` já com `operadorAlocadoId`, o auto-alloc NÃO roda, e create + `DemandaLog`
> (`acao: 'alocar'`, ator `USER`, `dados.origem: 'manual_criacao'`) são atômicos (mesma
> transação). Schema: `criarDemandaGestaoSchema` (superset de `criarDemandaSchema`, mesmo
> arquivo). Ver DEC tática `memory/decisions/2026-07-15-criar-demanda-gestao-operador-id.md`.

**Response 201 (`DemandaResumoDto`):**
```json
{
  "id": "uuid",
  "estado": "PENDENTE",
  "descricao": "string | null",
  "material": "string | null",
  "operadorAlocadoId": "string | null",
  "criadoEm": "ISO8601",
  "servicoNome": "string | null",
  "prioridade": "MAXIMA | ELEVADA | NORMAL | null",
  "localResumo": "string | null — 'Q07 / L12' | nome do local externo; com destino externo 'origem → destino'",
  "solicitanteNome": "string | null — empreiteira.nome, fallback criadoPor.nome"
}
```

> `estado = PENDENTE` no MVP-15jul (auto-alloc T3.4 já ativo). `operadorAlocadoId` = `null` se sem operador disponível. `servicoId` (FK) NÃO é exposto no response (persistido write-only); a leitura estruturada rasa (servicoNome, prioridade, localResumo, solicitanteNome) é exposta desde 2026-07-14 (design card-demanda-rico-campo).

**Erros:**
- `400` Zod — shape inválido (localTipo↔FK de local; destino both-or-neither)
- `404 DEM-006` — `servicoId` não encontrado no catálogo global
- `404 DEM-009` — local de origem (`quadraId`/`loteId`/`localExternoId`) ou destino (`destinoQuadraId`/`destinoLoteId`) não encontrado na obra (ou lote não pertence à quadra)
- `422 DEM-005` — inconsistência transporte/destino (bidirecional): destino ausente quando `exigeTransporte=true` · OU destino/`transporteInterno` enviados a serviço que não exige transporte
- `400 DEM-007` — material obrigatório ausente (`categoria=MOVIMENTACAO`)
- `400 DEM-008` — material informado não se aplica ao serviço (`categoria≠MOVIMENTACAO`)
- `422 DEM-010` — `tipoMaquinarioId` não compatível com o serviço (não pertence ao conjunto de tipos vinculados ao `servicoId`)
- `422 DEM-013` — **amendment 2026-07-16 (compat operador↔tipo, design `docs/superpowers/specs/2026-07-16-compat-operador-tipo-maquinario-design.md`, DEC `memory/decisions/2026-07-16-compat-operador-tipo-alocacao-manual.md`):** `operadorId` (gestão) informado no body não é habilitado no `tipoMaquinarioId` da demanda (sem registro em `OperadorTipoMaquinario`). Checado após o `404 TEN-001` do operador e ANTES de persistir (fail-fast, mesmo racional do amendment 2026-07-15). Só se aplica quando `operadorId` está presente no request — sem `operadorId`, a demanda segue para o auto-allocator (que já hard-filtra por compat).

---

### POST /demandas/bulk — Criar múltiplas demandas _(pós-MVP — não implementado)_

> ⚠️ **Não implementado no MVP-15jul.** Sem controller/rota correspondente em `apps/api` (verificado 2026-07-18). Criação de demandas é uma-a-uma via `POST /demandas`. Mantido como contrato de roadmap.

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

### GET /demandas — Listar demandas _(pós-MVP — não implementado como rota genérica)_

> ⚠️ **Não implementado no MVP-15jul.** Não há `GET /demandas` root nem `GET /demandas/:id` genéricos em `apps/api` (verificado 2026-07-18). As leituras reais são especializadas por consumidor: `GET /demandas/minhas`, `GET /demandas/fila`, `GET /demandas/kanban`, `GET /demandas/fila-gestao`, `GET /demandas/dashboard`. O campo `score` abaixo é **pré-pivot** (motor de priorização é pós-MVP, `DEC-024`). Mantido como contrato de roadmap.

**Perfis:** todos (escopo filtrado por perfil/obraId)

**Query params:** `?status=&operadorId=&servicoId=&setorId=&page=&limit=`

**Response 200:** lista paginada de demandas com campos principais (id, status, score, localTipo, criadoEm, empreiteiro, operador, `rolloverDe`)

> O campo `rolloverDe: date | null` (DEC-025) é incluído em todas as respostas que retornam demandas (listagem, detalhe e kanban). Indica a data de origem do rollover — `null` para demandas do dia corrente; data ISO 8601 (dia) para demandas redistribuídas de dia anterior.

---

### GET /demandas/:id — Detalhe de demanda _(pós-MVP — não implementado)_

> ⚠️ **Não implementado no MVP-15jul** (ver nota em `GET /demandas`). Detalhe de demanda é servido embutido nas projeções especializadas (kanban/fila-gestão). Mantido como contrato de roadmap.

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

> **⚠️ Contrato divergente do implementado (débito T5.3, fora do escopo deste amendment):**
> o in-tree responde `{ id, estadoAnterior, estadoNovo }` (não `statusAnterior/statusNovo/logId`)
> e o enum `acao` é ESTRITO `['iniciar','concluir']` no MVP (demais ações → `400`) — ver
> `memory/decisions/2026-06-23-t5.3-transicoes-alocacao-fila.md` D3. Pendente de amendment próprio.
>
> **Amendment 2026-07-11 — Slice 7 (resolve o pendente acima):** o contrato in-tree passa a
> canônico e definitivo (Rule 15). Enum `acao` = 6 valores
> (`iniciar | concluir | pausar | retomar | cancelar | devolver`) — `antecipar` segue fora do
> MVP (`400` se enviado). `justificativa` é condicional: obrigatória em
> `pausar`/`cancelar`/`devolver` (mínimo 10 caracteres pós-trim), opcional nas demais. Response
> `200`: `{ id, estadoAnterior, estadoNovo }` — **sem `logId`** (descarte deliberado, FE não
> consome). O débito de nomes `statusAnterior/statusNovo` do bloco JSON do request/response
> acima permanece documentado como divergência histórica, não mais como pendência em aberto.
> **422 relaxado:** exigido apenas nas ações com vínculo de Operador
> (`iniciar/concluir/pausar/retomar`); `cancelar/devolver` seguem direto para as specifications
> de ownership mesmo com `atorOperadorId` ausente. Ver DEC tática
> `memory/decisions/2026-07-10-slice-7-transicoes-http-ui.md` (pontos 5–6).
>
> **`DemandaLog` (ponto 7):** toda transição bem-sucedida das 6 ações grava **uma entrada**
> em `DemandaLog` (`acao`, `estadoAnterior`, `estadoNovo`, `userId`, `justificativa` quando
> presente, `obraId`) na MESMA transação da atualização da demanda. `DemandaLog` é tenant
> DIRETO desde a Slice 7 (coluna `obraId` própria, migration
> `20260711100000_demanda_log_obra_id`) — não mais herdado via `Demanda`. `alocar`/`reordenar`
> (gestão de fila) NÃO gravam log nesta slice — follow-up registrado na DEC. Ver DEC tática
> `memory/decisions/2026-07-10-slice-7-transicoes-http-ui.md` (ponto 7).

---

### GET /demandas/fila — Fila do Operador autenticado (self-scoped)

**Rastreio:** `REQ-RBAC-003` · DEC `2026-06-23-t5.3-transicoes-alocacao-fila` (D4)

**Perfis:** `Operador` (self-scoped — resolve `Operador.id` a partir de `req.user.sub`)

> Rota FLAT, array puro (Rule 19 — coleção bounded por operador). Diverge deliberadamente
> do envelope `{operadorId, expedienteAtivo, fila}` de `GET /operadores/:id/fila` (§4,
> contrato pré-pivot) — sem `score`/SLA/`posicaoFila` calculado, ver DEC acima.

**Response 200 (`DemandaResumoDto[]`):**
```json
[
  {
    "id": "uuid",
    "estado": "PENDENTE | EM_ANDAMENTO | PAUSADA",
    "descricao": "string | null",
    "material": "string | null",
    "operadorAlocadoId": "uuid",
    "criadoEm": "ISO8601",
    "servicoNome": "string | null",
    "prioridade": "MAXIMA | ELEVADA | NORMAL | null",
    "localResumo": "string | null — 'Q07 / L12' | nome do local externo; com destino externo 'origem → destino'",
    "solicitanteNome": "string | null — empreiteira.nome, fallback criadoPor.nome"
  }
]
```

> **Ordenação (gap §3.3, fix Slice 6 T6.2 — DEC `2026-07-07-kanban-endpoint-unico-rbac-ampliado`):**
> `posicaoFila ASC NULLS LAST, criadoEm ASC`, calculada em JS (`comparePosicaoFila`) — SQL
> Server ordena `NULL` primeiro em `ASC`, o que inverteria o NULLS LAST. Demandas ainda não
> tocadas por `POST /demandas/:id/reordenar` (sem `posicaoFila`) caem no fim, desempatadas
> por `criadoEm`.

**Erros:** `422` usuário autenticado sem cadastro de Operador (`{message}`, sem `error` sentinel) · `401/403` guards globais.

---

### POST /demandas/:id/alocar — Alocar operador manual (T6.4)

**Rastreio:** `REQ-RBAC-003` · Design: `docs/superpowers/specs/2026-07-07-slice-6-kanban-demandas-ml-design.md` (modal Alocar) · Amendment compat operador↔tipo: `docs/superpowers/specs/2026-07-16-compat-operador-tipo-maquinario-design.md` · DEC `memory/decisions/2026-07-16-compat-operador-tipo-alocacao-manual.md`

**Perfis:** `TowerOperator`, `AdminOperacional`, `SuperAdmin` (`DEMANDA_FILA_WRITE_PERFIS` — mesmo trio de gestão do `reordenar`; `Board`/`UsuarioInternoFGR` são read-only no kanban)

> Aloca (ou realoca) o operador de uma demanda já persistida — usado pelo modal "Alocar" do kanban (T6.4). Diferente da pré-alocação em `POST /demandas` (só se aplica na criação), este endpoint muta uma demanda existente em qualquer estado; a validade da mutação em si (ex.: demanda já `CONCLUIDA`) é checada pelo aggregate (`Demanda.alocar()`).

**Request (`AlocarDemandaDto`, schema `alocarDemandaSchema`):**
```json
{ "operadorId": "uuid" }
```

**Response 200 (`DemandaResumoDto`):** mesmo shape do `POST /demandas/:id/reordenar` (abaixo).

**Erros:** `400` validação (`operadorId` ausente ou não-uuid) · `400 RBAC-003` contexto de obra ausente (SuperAdmin sem `X-Tenant-Obra-Id`) · `404 TEN-001` operador não encontrado no tenant OU demanda não encontrada no tenant · `422 DEM-013` operador não habilitado no tipo de maquinário da demanda (checado após os dois `404 TEN-001`, antes de persistir; **pulado quando `demanda.tipoMaquinarioId = null`** — carve-out legado, mesmo do auto-allocator) · `403 RBAC-001` autorização de domínio (aggregate) · `409 DEM-003` transição/mutação inválida (aggregate) · `401/403` guards globais.

---

### POST /demandas/:id/reordenar — Reordenar fila manual (T6.1)

**Rastreio:** `REQ-RBAC-003` · Design: `docs/superpowers/specs/2026-07-07-slice-6-kanban-demandas-ml-design.md` §3.2/D4/D5 · DEC `2026-07-07-posicao-fila-fractional-indexing-bin2`

**Perfis:** `TowerOperator`, `AdminOperacional`, `SuperAdmin` (mutação restrita ao trio de gestão — D8; `Board`/`UsuarioInternoFGR` são read-only no kanban)

> **Contrato de intenção** (diverge da spec-mãe §7.3 — `{posicaoFila}` client-side NÃO
> implementado): o cliente informa "depois de qual demanda" (`aposDemandaId`) e o SERVIDOR
> calcula a chave `fractional-indexing` lendo os vizinhos atuais. Snapshot stale no cliente
> (polling 10s) não corrompe a fila.

**Request (`ReordenarDemandaDto`, `.strict()`):**
```json
{ "aposDemandaId": "uuid | null" }
```
`null` = mover para o topo da fila.

**Response 200 (`DemandaResumoDto`):**
```json
{
  "id": "uuid",
  "estado": "string",
  "descricao": "string | null",
  "material": "string | null",
  "operadorAlocadoId": "uuid | null",
  "criadoEm": "ISO8601",
  "servicoNome": "string | null",
  "prioridade": "MAXIMA | ELEVADA | NORMAL | null",
  "localResumo": "string | null — 'Q07 / L12' | nome do local externo; com destino externo 'origem → destino'",
  "solicitanteNome": "string | null — empreiteira.nome, fallback criadoPor.nome"
}
```

> **Nota (DEC 2026-07-17 — `memory/decisions/2026-07-17-sla-removido-ui-redefinicao-por-servico.md`):**
> `rolloverInicioSla`/`prioridade` permanecem no contrato do `DemandaResumoDto` (sem churn), mas a UI
> **não** os deriva mais para SLA (countdown/alvo/"estourado") — nenhuma superfície de UI exibe SLA.
> `prioridade` segue usado para o badge de prioridade (ordenação da fila, conceito separado).

**Erros:** `400` validação (`aposDemandaId` ausente ou não-uuid) · `400 RBAC-003` contexto de obra ausente (SuperAdmin sem `X-Tenant-Obra-Id`) · `404 TEN-001` demanda não encontrada no tenant · `422 DEM-011` `aposDemandaId` inválido (precisa ser outra demanda `PENDENTE` da mesma obra) · `422 DEM-012` fila precisa de rebalanceamento (chave gerada > 64 chars, ou colisão de chaves sob escrita concorrente — D4, sem lock/retry no MVP) · `403 RBAC-001` autorização de domínio · `409 DEM-003` transição de estado inválida · `401/403` guards globais.

---

### GET /demandas/kanban — Kanban ML, 4 colunas (T6.2)

**Rastreio:** `REQ-RBAC-003` · Design: `docs/superpowers/specs/2026-07-07-slice-6-kanban-demandas-ml-design.md` §3.1/§4.3/D2/D8/D9 · DEC `2026-07-07-kanban-endpoint-unico-rbac-ampliado`

**Perfis (RBAC ampliado — D8, `DEMANDA_KANBAN_READ_PERFIS`):** `TowerOperator`, `AdminOperacional`, `SuperAdmin` (gestão, leitura+mutação via `reordenar`/`alocar`) + `Board`, `UsuarioInternoFGR` (read-only)

> Response ÚNICO (D2): colunas + contadores + `operadores[]` embutidos p/ o modal de
> alocar (T6.4) — evita um 2º endpoint. `OPERADOR_READ_PERFIS` do catálogo admin
> permanece intacta (`TowerOperator` segue excluído do CRUD de Operador).

**Response 200 (`KanbanDto`):**
```json
{
  "pendentes": "DemandaKanbanCardDto[] — posicaoFila ASC NULLS LAST, criadoEm ASC",
  "emAndamento": "DemandaKanbanCardDto[] — iniciadoEm ASC (fallback criadoEm)",
  "pausadas": "DemandaKanbanCardDto[] — criadoEm ASC",
  "concluidasHoje": "DemandaKanbanCardDto[] — finalizadoEm DESC, limit 50",
  "contadores": {
    "pendentes": "number",
    "emAndamento": "number",
    "pausadas": "number",
    "concluidasHoje": "number (count REAL — pode exceder o array, que é capado em 50)"
  },
  "operadores": [
    {
      "id": "uuid",
      "nome": "string",
      "emExpediente": "boolean",
      "tiposAutorizadosIds": "string[] — NOVO (amendment 2026-07-16, compat operador↔tipo): ids de TipoMaquinario com registro em OperadorTipoMaquinario (habilitação estática)",
      "tipoMaquinarioAtualId": "string | null — NOVO: TipoMaquinario do maquinário do expediente aberto (RegistroExpediente → Maquinario.tipoMaquinarioId); null se fora de expediente"
    }
  ]
}
```

> `contadores.concluidasHoje` é o count real do dia (não o `length` do array capado em
> 50) — o FE usa este contador (não o `length`) também nos headings das 4 colunas.
>
> **Amendment 2026-07-16 — compat operador↔tipo (`OperadorKanbanDto.tiposAutorizadosIds` /
> `tipoMaquinarioAtualId`, design `docs/superpowers/specs/2026-07-16-compat-operador-tipo-maquinario-design.md`,
> DEC `memory/decisions/2026-07-16-compat-operador-tipo-alocacao-manual.md`):** sem query
> nova — `KanbanQueryService` passa a selecionar `tiposMaquinarioAutorizados` (via
> `OperadorTipoMaquinario`) na query de operadores e `maquinario.tipoMaquinarioId` na query
> de expedientes abertos. Consumido pelo FE (modal Alocar / dialog Criar Demanda) para
> exibir operador incompatível como visível-porém-desabilitado no Combobox — ver
> `DemandaKanbanCardDto.tipoMaquinarioId` abaixo e `422 DEM-013` nos write paths
> (`POST /demandas`, `POST /demandas/:id/alocar`).

`DemandaKanbanCardDto`:
```json
{
  "id": "uuid",
  "estado": "PENDENTE | EM_ANDAMENTO | PAUSADA | CONCLUIDA",
  "servicoNome": "string | null (null p/ legado free-text)",
  "prioridade": "MAXIMA | ELEVADA | NORMAL | null — NOVO (amendment design 2026-07-17): servico.prioridade, exibido como PrioridadeChip",
  "solicitanteNome": "string | null — NOVO (amendment design 2026-07-17): empreiteira.nome, fallback criadoPor.nome",
  "material": "string | null (nome do catálogo ou materialTexto — shim Slice 9)",
  "localResumo": "string | null (\"quadra / lote\" ou nome do local externo)",
  "operadorAlocado": "{ id: uuid, nome: string } | null (null = demanda órfã)",
  "criadoEm": "ISO8601",
  "iniciadoEm": "ISO8601 | null",
  "finalizadoEm": "ISO8601 | null",
  "posicaoFila": "string | null",
  "tipoMaquinarioId": "string | null — NOVO (amendment 2026-07-16, compat operador↔tipo): p/ o modal Alocar filtrar/desabilitar operadores incompatíveis; null = demanda legado (sem check no POST /demandas/:id/alocar)"
}
```

> **Amendment 2026-07-17 — `prioridade` + `solicitanteNome` (design
> `docs/superpowers/specs/2026-07-17-gestao-dashboard-fila-design.md` §3.4):** o card do kanban
> ganha `PrioridadeChip` (badge de prioridade — ordenação da fila, conceito separado de SLA) e o
> nome do solicitante. **Não** é reintrodução de SLA na UI — ver DEC
> `memory/decisions/2026-07-17-sla-removido-ui-redefinicao-por-servico.md`.

> **"Hoje" (D9):** dia corrente em `America/Sao_Paulo` (env `TZ`), corte
> `finalizadoEm >= startOfDay` (`startOfDayInTimeZone`, puro, `dia-operacional.ts`).

> **Throttling (DEC `2026-07-07-throttler-auth-bucket-blanketa-demandas`, resolução
> estrutural):** o bucket `auth` (5/min) vale SOMENTE nas rotas de credencial que
> optam via `@AuthRateLimit()` (`skipIf` no registro do throttler) — nenhuma rota
> precisa de `@SkipThrottle({auth})`. Todas as rotas de `/demandas` (incl. `kanban`)
> são governadas pelo bucket `default` (20 req/min), suficiente para o polling do
> FE (10s, ~6 req/min). Resumo por endpoint: §9.

**Erros:** `400 RBAC-003` contexto de obra ausente (perfil bypass — SUPER_ADMIN/BOARD — sem `X-Tenant-Obra-Id`) · `401` sem token · `403 RBAC-001` perfil fora de `DEMANDA_KANBAN_READ_PERFIS`.

---

### GET /demandas/fila-gestao — Fila de gestão obra-wide (Novo, design 2026-07-17)

**Rastreio:** `REQ-FUNC-009`, `REQ-FUNC-011`, `REQ-FUNC-013` · Design: `docs/superpowers/specs/2026-07-17-gestao-dashboard-fila-design.md` §3.1

**Perfis (`DEMANDA_KANBAN_READ_PERFIS`):** `TowerOperator`, `AdminOperacional`, `SuperAdmin` (gestão) + `Board`, `UsuarioInternoFGR` (read-only) — mesmo conjunto do kanban.

> Projeção da view Fila da tela de gestão — superset do `DemandaResumoDto` (`FilaGestaoItemDto`), obra-wide (todas as demandas ativas, não self-scoped como `GET /demandas/fila` do Operador). Coleção unbounded-mas-operacional (demandas ativas do dia — mesma classe do kanban): array puro dentro do envelope `{ itens }`, sem paginação (DEC 2026-06-11 carve-out).

**Response 200 (`FilaGestaoDto`):**
```json
{
  "itens": [
    {
      "id": "uuid",
      "estado": "PENDENTE | EM_ANDAMENTO | PAUSADA",
      "descricao": "string | null",
      "material": "string | null",
      "operadorAlocadoId": "uuid | null",
      "criadoEm": "ISO8601",
      "servicoNome": "string | null",
      "prioridade": "MAXIMA | ELEVADA | NORMAL | null",
      "localResumo": "string | null — 'Q07 / L12' | nome do local externo; com destino externo 'origem → destino'",
      "solicitanteNome": "string | null — empreiteira.nome, fallback criadoPor.nome",
      "rolloverInicioSla": "ISO8601 | null — permanece no contrato, UI não deriva SLA (DEC 2026-07-17)",
      "operadorAlocado": "{ id: uuid, nome: string } | null",
      "iniciadoEm": "ISO8601 | null",
      "posicaoFila": "string | null — FE deriva '⚑ manual' = !== null"
    }
  ]
}
```

> **Ordenação server-side por grupo de estado:** `EM_ANDAMENTO` (`iniciadoEm` ASC, fallback `criadoEm`) →
> `PAUSADA` (`criadoEm` ASC) → `PENDENTE` (`posicaoFila` ASC NULLS LAST byte-order, `criadoEm` ASC —
> mesma `comparePosicaoFila` do kanban/reordenar). Filtro: `obraId` + `deletadoEm: null` + estado em
> `{PENDENTE, EM_ANDAMENTO, PAUSADA}`. KPIs da view (ativas/por estado/⚑ manual/operadores parados)
> são derivados no FE a partir de `itens` — nenhum agregado no response.

**Erros:** `400 RBAC-003` contexto de obra ausente (SuperAdmin sem `X-Tenant-Obra-Id`) · `401` sem token · `403 RBAC-001` perfil fora de `DEMANDA_KANBAN_READ_PERFIS`.

---

### GET /demandas/dashboard — Agregados do dia da gestão (Novo, design 2026-07-17)

**Rastreio:** `REQ-FUNC-009`, `REQ-FUNC-011`, `REQ-FUNC-013` · Design: `docs/superpowers/specs/2026-07-17-gestao-dashboard-fila-design.md` §3.2

**Perfis (`DEMANDA_KANBAN_READ_PERFIS`):** `TowerOperator`, `AdminOperacional`, `SuperAdmin` + `Board`, `UsuarioInternoFGR` (read-only) — mesmo conjunto do kanban/fila-gestao.

> Janela do dia = `startOfDayInTimeZone(now, TZ)` — mesma fonte do "Hoje" do kanban (D9). `tempoMedioResolucao` mede **resolução** (`finalizadoEm − criadoEm`, criação→conclusão) — **não** é SLA e **não** é `tempoExecucaoMs` (que mede só execução). Ver DEC `memory/decisions/2026-07-17-sla-removido-ui-redefinicao-por-servico.md`.

**Response 200 (`DashboardGestaoDto`):**
```json
{
  "contadores": {
    "criadasHoje": "number — criadoEm >= início do dia operacional (qualquer estado atual)",
    "pendentes": "number — estado atual, não restrito a hoje",
    "emAndamento": "number",
    "pausadas": "number",
    "concluidasHoje": "number — finalizadoEm >= início do dia (count real, como no kanban)"
  },
  "tempoMedioResolucao": {
    "geralMs": "number | null — média de (finalizadoEm - criadoEm) das concluídas hoje; null se 0 concluídas",
    "porPrioridade": { "MAXIMA": "number | null", "ELEVADA": "number | null", "NORMAL": "number | null" }
  },
  "operadoresEmExpediente": [
    { "operadorId": "uuid", "nome": "string", "maquinarioNome": "string" }
  ]
}
```

> Demandas legadas sem `servicoId` entram no `geralMs` e ficam fora do `porPrioridade`.
> `operadoresEmExpediente` — turnos abertos (`RegistroExpediente.fimExpediente = null`) da obra,
> ordenado por nome pt-BR.

**Erros:** `400 RBAC-003` contexto de obra ausente (SuperAdmin sem `X-Tenant-Obra-Id`) · `401` sem token · `403 RBAC-001` perfil fora de `DEMANDA_KANBAN_READ_PERFIS`.

---

### POST /demandas/fila/restaurar — Restaurar fila ao FIFO (Novo, design 2026-07-17)

**Rastreio:** `REQ-JOR-005` (auditoria administrativa) · Design: `docs/superpowers/specs/2026-07-17-gestao-dashboard-fila-design.md` §3.3

**Perfis (`DEMANDA_FILA_WRITE_PERFIS`):** `TowerOperator`, `AdminOperacional`, `SuperAdmin` (mesmo trio de gestão do `reordenar`/`alocar`; `Board`/`UsuarioInternoFGR` ficam `403`).

> Limpa `posicaoFila` de **todas** as `PENDENTE`s da obra — a fila volta ao FIFO puro (`criadoEm` ASC).
> Sem passagem pelo aggregate (a mutação não transita estado); update + logs na mesma transação.
> **Idempotente:** rodar sem nenhuma `posicaoFila` manual retorna `{ restauradas: 0 }` — sucesso, não erro.
> ⚠️ **Rota estática declarada ANTES de `:id/*`** no controller (hygiene de rota — `fila/restaurar` não
> pode ser capturada pelo param `:id`).

**Request:** sem body.

**Response 200:**
```json
{ "restauradas": "number" }
```

**Auditoria:** 1 `DemandaLog` por demanda com `posicaoFila` manual (não-null) afetada — `acao: "restaurar_ordem_fila"`, `estadoAnterior`/`estadoNovo: "PENDENTE"`, `ator: "USER"`, `dados: { posicaoAnterior }` (mesmo padrão do `reordenar`). Demandas já com `posicaoFila = null` não geram log.

**Erros:** `400 RBAC-003` contexto de obra ausente (SuperAdmin sem `X-Tenant-Obra-Id`) · `401` sem token · `403 RBAC-001` perfil fora de `DEMANDA_FILA_WRITE_PERFIS`.

---

## 3b. Ciclo de aceite de demandas agendadas (`/demandas/:id/...`)

**Rastreio PRD:** `REQ-FUNC-006`, `REQ-FUNC-014`

> ⚠️ **Seção inteira não implementada no MVP-15jul.** O fluxo `AGENDADA` (aceite/recusa/aprovação/cancelamento) está **fora do escopo do MVP** — nenhum dos endpoints desta seção existe em `apps/api` (verificado 2026-07-18), e o próprio `POST /demandas` removeu `urgencia`/`dataAgendada` do contrato ("fora do escopo MVP-15jul"). Mantida integralmente como contrato de roadmap (DEC-026 a DEC-029).

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

> **Reconciliação de rota (T4.2, DEC-044):** `/operadores` agrega dois contratos
> distintos — o **cadastro administrativo** (CRUD abaixo, T4.2) e as leituras
> **operacionais** de fila/disponibilidade (`GET /operadores/:id/fila` e
> `GET /operadores/disponiveis`, Slice 5/6). `GET /operadores` (raiz) é a lista de
> **cadastro paginada**; a disponibilidade de fila fica em `GET /operadores/disponiveis`
> (sub-rota distinta — não sobrescreve a raiz).

**Rastreio PRD (cadastro de Operador, T4.2):** `REQ-RBAC-001`, `REQ-RBAC-005`, `REQ-RBAC-006` (Gestão de Acessos — provisão de Operadores com PIN e habilitações; SPEC/04 `machinery:operador:*`). Habilita `REQ-FUNC-001`/`REQ-FUNC-002` (alocação/execução, que pressupõem operadores cadastrados). _Nota: a tag `REQ-FUNC-012` que aparece em commits da T4.2 é da família CRUD `/usuarios` (Empreiteira); o REQ próprio do cadastro de Operador é `REQ-RBAC-001` (DEC-044)._

### POST /operadores — Criar operador (cadastro atômico) — T4.2

**Perfis:** `SuperAdmin`, `AdminOperacional` (machinery:operador:create)

> **Caminho ÚNICO de criação de Operador** (DEC-044): cria `User(OPERADOR)` +
> `Operador` + autorizações N:M numa única transação atômica (hash do PIN fora da
> tx). `POST /usuarios` **não** aceita mais `perfil=OPERADOR` (→ 400). Supera essa
> parte de DEC-042/043.
>
> **T4.4 — PIN gerado no servidor:** o create **não** aceita `pin` no body
> (`.strict()` ⇒ enviar `pin` → 400). O sistema gera o PIN de 6 dígitos
> (`PinGeneratorService`, mesma fonte do reset T4.3) e o devolve em claro **uma
> única vez** na resposta. Supera a nota anterior ("Admin informa o PIN").
>
> **Elegibilidade por MÁQUINA (ADR 0004):** o create ganha `maquinariosIds` — a
> cascata tipo→máquina do `OperadorMaquinario` (portão do check-in), distinta da
> competência por `TipoMaquinario`. Toda máquina informada deve pertencer a um
> `tipoMaquinarioId ∈ tiposMaquinarioIds` do mesmo request — violação ⇒
> `422 OPR-012`. Máquina inexistente ou fora do tenant ⇒ `404 TEN-001`.

**Request (`createOperadorSchema`, `.strict()`):**
```json
{
  "nome": "string (min 1)",
  "cpf": "string (cpfSchema — 11 dígitos, dígito verificador) → 400 se inválido",
  "email": "string | null (OPCIONAL)",
  "obraId": "uuid (só SuperAdmin; AdminOperacional ignora; obrigatório p/ SuperAdmin → 400 OPR-010 se ausente)",
  "tiposMaquinarioIds": "uuid[] (deduplicado; ≥0 permitido)",
  "maquinariosIds": "uuid[] (deduplicado; default [] — ADR 0004; cascata: cada máquina deve pertencer a um tipo em tiposMaquinarioIds)"
}
```
**Response 201 (T4.4):** `{ operador: OperadorView, pin: "string (6 dígitos, gerado no servidor, claro 1×)" }`. `OperadorView` permanece sem `pin`/`pinHash` (reusado por GET/list/PATCH).
**Erros:** `400` validação / `400 OPR-010` SuperAdmin sem `obraId` · `404` obra não encontrada / `404 OPR-008` tipoMaquinario inexistente / `404 TEN-001` máquina inexistente ou fora do tenant · `422 OPR-012` máquina fora dos tipos habilitados (cascata, ADR 0004) · `409 USR-004` CPF duplicado / `409 USR-001` email duplicado / `409 OPR-009` operador já existe p/ user (backstop) · `401/403`.

### GET /operadores — Listar operadores (cadastro admin, paginado) — T4.2

**Perfis:** `SuperAdmin`/`Board` (cross-tenant) · `AdminOperacional`/`UsuarioInternoFGR` (escopo da obra — barreira de tenant explícita)

**Query:** `?page=&limit=&obraId=(só bypass)&search=(nome/cpf)`
**Response 200:** `{ data: OperadorView[], total, page, limit }` — filtra `user.deletadoEm: null`.

### GET /operadores/:id — Detalhe de operador — T4.2

**Perfis:** idem GET lista. **Response 200:** `OperadorView`. `404` fora do tenant / inexistente / user soft-deletado.

### PATCH /operadores/:id — Re-autorizar (replace-whole-set N:M + máquinas) — T4.2 / ADR 0004

**Perfis:** `SuperAdmin`, `AdminOperacional` (machinery:operador:update). **Request (`updateOperadorSchema`, `.strict()`):** `{ "tiposMaquinarioIds": "uuid[]", "maquinariosIds": "uuid[]" }` (**ambos obrigatórios**; ausência de qualquer um → 400). Idempotente: substitui os **dois** conjuntos (`OperadorTipoMaquinario` e `OperadorMaquinario`) atomicamente na mesma transação — replace-whole-set combinado (ADR 0004 D6). Valida cascata: toda máquina em `maquinariosIds` deve ter `tipoMaquinarioId ∈ tiposMaquinarioIds` do mesmo request. **Response 200:** `OperadorView`. Edita **só** autorizações (identidade via `PATCH /usuarios/:id`). **Erros adicionais:** `404 OPR-008` tipoMaquinario inexistente · `404 TEN-001` máquina inexistente/cross-tenant · `422 OPR-012` violação de cascata (máquina fora dos tipos habilitados).

### DELETE /operadores/:id — Excluir operador (soft-delete) — T4.2

**Perfis:** `SuperAdmin`, `AdminOperacional` (machinery:operador:delete)

Soft-delete do `User(OPERADOR)` (UPDATE `deletadoEm`, nunca hard-delete — preserva
histórico de expediente/demanda). Reusa a política de remoção de `DELETE /usuarios/:id`
(fonte única): bloqueia se houver **dependência ativa** (ex.: expediente aberto). O
operador some das leituras (`ativo` deriva de `deletadoEm`).
**Response 204** (No Content). **Erros:** `404` fora do tenant / inexistente · `409` dependências ativas (expediente aberto) · `401/403`.

### POST /operadores/:id/pin/reset — Resetar PIN (Admin gera, vê 1×) — T4.3

**Perfis:** `SuperAdmin`, `AdminOperacional` (machinery:operador:update)

> **Reset-only** (T4.3): o sistema **gera** o PIN novo (6 dígitos) e o aplica ao
> Operador; o Admin vê o PIN em claro **uma única vez** na resposta.
> O create (`POST /operadores`, §4) foi reaberto na **T4.4**: agora o servidor
> também gera o PIN no create (mesma fonte deste reset). `:id` = `Operador.id`.
>
> **Divergência deliberada do título do roadmap** (`POST /usuarios/:id/pin/reset`
> → `POST /operadores/:id/pin/reset`): o reset segue o Operador, que a T4.2 moveu
> integralmente para `/operadores` (DEC-044 baniu `perfil=OPERADOR` de `/usuarios`).
> Rota canônica = `/operadores`.

**Request:** **sem body**. O sistema gera o PIN.

**Response 200:**
```json
{ "pin": "654321" }
```
> PIN em claro, 6 dígitos (zeros à esquerda permitidos). Retornado **uma única
> vez**; depois irrecuperável (só o `pinHash` bcrypt persiste). **Nunca** logado em
> claro. Nenhum endpoint expõe o PIN em claro ou o `pinHash`.

**Comportamento:** zera o contador/bloqueio de **lockout** do operador (best-effort —
o motivo nº1 do reset é o operador travado). Não seta `senhaTrocadaEm` (PIN não
rastreia rotação).

**Erros:** `404` operador inexistente / **cross-tenant** / user soft-deletado ·
`403 RBAC-003` non-bypass sem contexto de obra (fail-closed) · `401/403` guards
globais (JWT / perfil sem permissão de escrita). **Sem `400`** (não há body).

**Rastreio PRD:** `REQ-RBAC-001` (Gestão de Acessos — manutenção de credenciais de
Operador), `REQ-NFR-007` (política de PIN — DEC-004).

### OperadorView
```json
{
  "id": "uuid", "userId": "uuid", "nome": "string",
  "cpf": "string MASCARADO (***.***.***-DD, LGPD)",
  "email": "string | null", "obraId": "uuid",
  "ativo": "boolean (user.deletadoEm === null)",
  "tiposMaquinario": [{ "id": "uuid", "nome": "string" }],
  "maquinarios": [{ "id": "uuid", "nome": "string", "tipoMaquinarioId": "uuid" }]
}
```
NUNCA expõe `pinHash`. `maquinarios` (ADR 0004) é o conjunto `OperadorMaquinario` — máquinas específicas liberadas para o check-in; distinto de `tiposMaquinario` (competência).

---

### GET /operadores/:id/fila — Fila do operador

> Contrato pré-pivot (envelope `{operadorId, expedienteAtivo, fila}` com score/SLA). O
> self-scoped realmente implementado é `GET /demandas/fila` (§3) — ver DEC
> `2026-06-23-t5.3-transicoes-alocacao-fila` D4.

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

### GET /operadores/disponiveis — Listar operadores disponíveis (fila — Slice 5/6, não implementado)

> **Reconciliado em T4.2 (DEC-044):** movido da raiz `GET /operadores` (que passa a
> ser a lista de **cadastro admin**, acima) para a sub-rota `/operadores/disponiveis`.
> Leitura **operacional** de disponibilidade de fila — **não implementado** (Slice 5/6).

**Query params:** `?setorId=&turnoAtivo=`

**Response 200:** lista de operadores com `disponivel`, `setorOperacionalId`, `maquinarioAtualId`

---

### POST /expediente/checkin — Check-in de expediente

> **MVP-15jul (Slice 5, T5.2 — REQ-FUNC-004) — contrato em produção.** Rota FLAT
> self-scoped: opera sobre o turno do **Operador autenticado** (`req.user.sub`),
> sem `:id` (sem IDOR; espelha a convenção flat de `/demandas`). Substitui o
> antigo `POST /operadores/:id/checkin` (DEC `2026-06-19-t5.2-expediente-http-decisoes`).

**Perfil:** `Operador`

**Request:**
```json
{
  "maquinarioId": "uuid",
  "confirmarForaDaJanela": "boolean (opcional)"
}
```

> Schema `.strict()` — campo extra (ex.: `ajudanteId`, removido do MVP por DEC-041) → `400`.
>
> **Elegibilidade por MÁQUINA (ADR 0004):** após a checagem de existência da
> máquina no tenant (`TEN-001`) e antes da checagem de expediente duplicado
> (`OPR-003`), o use-case valida `maquinarioElegivelParaOperador` — a máquina
> deve estar liberada para o operador (`OperadorMaquinario`). Falha ⇒
> `403 OPR-011`. Primeiro portão de elegibilidade no check-in (antes inexistente).
>
> **Check-in fora do expediente da obra (amendment 2026-07-16, DEC-050,
> `REQ-FUNC-004`):** quando a obra tem expediente configurado (§`PATCH
> /obras/:id/configuracoes`) e o check-in ocorre fora da janela (`inicio..fim`
> do dia) ou em dia da semana fora de `diasAtivos`, o check-in exige
> confirmação explícita — `confirmarForaDaJanela: true`. Sem a flag ⇒ `422
> OPR-013`. Com a flag, o check-in prossegue e o `RegistroExpediente` é
> criado com `foraDaJanela = true` (persistido, informa a listagem de gestão
> — `GET /expedientes` abaixo). Obra sem expediente configurado (4 campos
> `null`) nunca aciona este check.

**Response 201 (`ExpedienteResumoDto`):**
```json
{ "id": "uuid", "maquinarioId": "uuid", "maquinarioNome": "string", "inicioEm": "ISO8601" }
```

**Erros:** `400` validação · `404 TEN-001` maquinário não encontrado no tenant · `403 OPR-011` máquina não liberada para este operador (ADR 0004) · `409 OPR-003` check-in duplicado · `422 OPR-013` fora do expediente da obra sem `confirmarForaDaJanela` — mensagem `"Check-in fora do expediente da obra (HH:MM–HH:MM). Confirme para prosseguir."` · `422` usuário sem cadastro de Operador (sem código §8 — fallback `UNPROCESSABLE_ENTITY`) · `401/403` auth/RBAC.

---

### POST /expediente/checkout — Checkout de expediente

**Rastreio PRD:** `REQ-FUNC-004`, `REQ-FUNC-014`

> **MVP-15jul (Slice 5, T5.2) — contrato em produção.** Rota FLAT self-scoped
> (Operador autenticado). Substitui `POST /operadores/:id/checkout`.

**Perfil:** `Operador`

**Request:** `{}` (corpo vazio; `.strict()` — sem `ajudanteId`).

> **Amendment 2026-07-16 (DEC-050, `REQ-FUNC-004`) — devolve, não bloqueia:** a
> alocação Demanda→Operador foi ligada nas slices seguintes e o checkout agora
> **devolve** (em vez de bloquear) as demandas do operador em `EM_ANDAMENTO`/
> `PAUSADA`: cada uma recebe `devolver_fim_expediente` (ator SISTEMA, DEC-025) →
> `PENDENTE`, com `DemandaLog` (`justificativa: "Devolução automática por fim de
> expediente"`). O checkout **nunca** retorna `409` por demanda em
> `EM_ANDAMENTO` — esse comportamento (parqueado na T5.1) foi superado; ver
> `OPR-005` (§8) para o código reservado à referência histórica. A hora extra é
> calculada e **congelada** em `RegistroExpediente.minutosHoraExtra` no momento
> do encerramento (`JanelaExpediente.minutosHoraExtra`, timezone
> `America/Sao_Paulo`). Este gatilho é **um dos dois** que processam fim de
> expediente — o outro é o worker `expedienteFim` (sweep 1min, Regra A/B — ver
> [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md)); o checkout
> cobre só as demandas do **próprio operador**, imediatamente.

**Response 200 (`FinalizarExpedienteResult`):**
```json
{
  "expedienteId": "uuid",
  "fimEm": "ISO8601",
  "minutosHoraExtra": "number (>= 0)",
  "demandasDevolvidas": "number (contagem — sem lista de IDs no MVP)"
}
```

**Erros:** `400` corpo inválido · `404 OPR-004` sem expediente ativo · `422` usuário sem cadastro de Operador · `401/403`.

---

### GET /expediente/ativo — Expediente aberto do operador

**Rastreio PRD:** `REQ-FUNC-004`

> **MVP-15jul (Slice 5, T5.2).** Retorna o expediente aberto do Operador
> autenticado, ou indica ausência. Sempre `200` com flag explícita (não `404`
> como empty-state — alinhado ao `expedienteAtivo` de `GET /operadores/:id/fila`).

**Perfil:** `Operador`

**Response 200 (`ExpedienteAtivoDto`):**
```json
{ "ativo": true,  "expediente": { "id": "uuid", "maquinarioId": "uuid", "maquinarioNome": "string", "inicioEm": "ISO8601" } }
{ "ativo": false, "expediente": null }
```

**Erros:** `401/403` · `422` usuário sem cadastro de Operador.

---

### GET /expediente/maquinarios-liberados — Máquinas liberadas para o operador

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-FUNC-004`

> **Novo (ADR 0004).** Leitura self-scoped para o PWA de campo (opera sobre o
> Operador autenticado, `req.user.sub` — mesma convenção flat de `/expediente/*`):
> lista as máquinas especificamente liberadas para o operador (`OperadorMaquinario`),
> fonte da tela "máquinas liberadas para você" no check-in (radio de seleção).

**Perfil:** `Operador`

**Response 200:** array puro (catálogo bounded por operador — Rule 19), filtra `deletadoEm: null` do maquinário:
```json
[{ "id": "uuid", "nome": "string", "placa": "string | null", "tipoMaquinarioNome": "string" }]
```

**Erros:** `422` usuário sem cadastro de Operador · `401/403`.

---

### GET /expedientes — Listagem de gestão de turnos (Novo, amendment 2026-07-16 — DEC-050)

**Rastreio PRD:** `REQ-FUNC-004`

**Perfis:** `OPERADOR_READ_PERFIS` (`SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`) — espelha `GET /operadores` (§4); **sem** `Operador` (essa é a rota self-scoped `GET /expediente/ativo` acima).

> **Rota flat de gestão** (`ExpedientesGestaoController`, `apps/api/src/machinery-link/expediente/expedientes-gestao.controller.ts`) — distinta da rota flat self-scoped `/expediente/*` do próprio Operador (arquivo separado, não reaproveita `@Controller('expediente')`). Lista os turnos de **todos os operadores da obra**, tenant-scoped via `$extends` do `PrismaService` (sem `where.obraId` manual). Consumida pela tela de gestão de Expedientes (grupo "Operação" na sidebar do módulo — `UI/Machinery-Link/07-configuracoes-obra.md` cobre só a config; a listagem em si não tem UI spec dedicada nesta amenda).

**Query:** `?page=&limit=` (`page` inteiro ≥1, default `1`; `limit` inteiro 1–100, default `20`).

**Response 200 (`PaginatedExpedientesGestao<Date>`) — paginado (Regra 19, coleção transacional unbounded):**
```json
{
  "data": [
    {
      "id": "uuid",
      "operadorNome": "string",
      "maquinarioNome": "string",
      "inicioEm": "ISO8601",
      "fimEm": "ISO8601 | null",
      "minutosHoraExtra": "number | null",
      "encerradoPorSistema": "boolean",
      "foraDaJanela": "boolean"
    }
  ],
  "total": "number",
  "page": "number",
  "limit": "number"
}
```

Ordenado por `inicioExpediente` desc. `fimEm`/`minutosHoraExtra` são `null` enquanto o turno está aberto. `encerradoPorSistema` distingue encerramento pelo worker `expedienteFim` (cutoff vencido) de checkout manual do operador. `foraDaJanela` reflete a confirmação de check-in fora da janela (`confirmarForaDaJanela`, ver `POST /expediente/checkin` acima).

**Erros:** `401/403`.

---

### POST /operadores/:id/ajudante — Trocar ajudante durante expediente

> **⚠️ Fora do MVP-15jul — adiado p/ Fase 2 (DEC-041, REQ-FUNC-004).** O suporte de domínio (`trocarAjudante`/`TurnoAjudante`) foi removido no T5.1; este contrato é referência pós-MVP.

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

> **OPERADOR removido deste endpoint (T4.2, DEC-044):** `perfil=Operador` **não é
> mais aceito** em `POST /usuarios` (→ `400`, discriminator inexistente no
> `createUsuarioSchema`). A criação de operador migrou para o caminho atômico
> `POST /operadores` (§4), fechando o estado órfão (User OPERADOR sem `Operador`).
> Supera essa parte de DEC-042/043.

```json
{
  "nome": "string (obrigatório)",
  "perfil": "SuperAdmin | Board | AdminOperacional | UsuarioInternoFGR | TowerOperator | Empreiteiro (obrigatório) — Operador NÃO (criação via POST /operadores)",
  "email": "string | null (obrigatório para os 5 perfis admin/mesa — SuperAdmin, Board, AdminOperacional, UsuarioInternoFGR, TowerOperator; opcional para Empreiteiro)",
  "cpf": "string (obrigatório para Empreiteiro — 11 dígitos com ou sem máscara, validado com dígito verificador; único global entre usuários ativos; imutável após criação; campo não aceito para perfis admin/mesa)",
  "obraId": "uuid (obrigatório para perfis tenant-scoped)",
  "empreiteiraId": "uuid | null (obrigatório quando perfil = Empreiteiro; nulo para demais perfis)",
  "password": "string (≥8 chars, 4 classes, obrigatório para os 5 perfis admin/mesa — SuperAdmin, Board, AdminOperacional, UsuarioInternoFGR, TowerOperator)"
}
```

> **D4 (2026-07-08):** `pin` **não é aceito** no payload de `Empreiteiro` — o
> servidor gera o PIN de 6 dígitos (`PinGeneratorService`, mesma fonte do
> Operador T4.4) e o devolve em claro **uma única vez** na resposta.

> O `AdminOperacional` só pode criar usuários com perfil hierárquico inferior ou igual dentro da mesma obra (condição [1] do RBAC); a criação de `Board` (perfil de bypass de tenant) é efetivamente exclusiva do `SuperAdmin`.
>
> **Schema canônico (`createUsuarioSchema`) — `discriminatedUnion` por `perfil`, cada branch `.strict()` (DEC-042, DEC-043; OPERADOR removido em DEC-044):**
> - **Perfis criáveis** incluem `TowerOperator` (perfil de mesa/Torre — credencial `password`, não PIN; ratificado por DEC-039/DEC-040) e `Board` (DEC-042). Os 5 perfis admin/mesa autenticam por `email`+`password`; `Empreiteiro` por `cpf`+`pin`. **`Operador` não é criável aqui** (→ `POST /operadores`, DEC-044).
> - **`cpf`** é exigido apenas em `Empreiteiro`; enviá-lo em perfil admin/mesa → `400` (`.strict()` rejeita campo fora do branch).
> - **`tiposMaquinarioIds` não é aceito** no `POST /usuarios` (DEC-043, divergência #3 da T4.1): a associação N:M `Operador ↔ TipoMaquinario` pertence ao cadastro de Operador (**T4.2**, `POST /operadores`). Enviar o campo → `400` (`.strict()`).

**Response 201:** para perfis com `password` (admin/mesa), shape flat de `User`:
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
Para `perfil = Empreiteiro` (D4, sem `password`), o servidor gera o PIN e a
resposta vem **envelopada**:
```json
{
  "usuario": { "id": "uuid", "nome": "string", "email": "string | null", "perfil": "EMPREITEIRO", "obraId": "uuid", "empreiteiraId": "uuid" },
  "pin": "string (6 dígitos, gerado no servidor, claro 1×)"
}
```

**Erros:** `400` campos obrigatórios ausentes ou campo não reconhecido no payload (`.strict()` — ex.: `tiposMaquinarioIds`, `cpf` em perfil admin/mesa) · `400` CPF inválido (dígito verificador) · `404` `empreiteiraId` ou `obraId` não encontrado · `409` email duplicado (`USR-001`) · `409` CPF já cadastrado para outro usuário ativo (`USR-004`) · `422` `empreiteiraId` informado para perfil diferente de Empreiteiro (`USR-003`)

---

### GET /usuarios/:id — Detalhe de usuário

**Perfis:** `SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`

**Response 200:** `User` completo com `id`, `nome`, `email`, `perfil`, `obraId`, `empreiteiraId`, `empreiteira` (expandido), `tiposMaquinario[]` (quando Operador)

**Erros:** `404` não encontrado · `403` tentativa de acessar usuário de outra obra (para perfis tenant-scoped)

---

### PATCH /usuarios/:id — Atualizar usuário

**Perfis:** `SuperAdmin`, `AdminOperacional` (condição [1])

**Request (UpdateUsuarioDto):** campos parciais de `CreateUsuarioDto` (exceto `perfil` e `cpf`, que são imutáveis — `updateUsuarioSchema` não recebe `cpf`; DEC-042)

**Response 200:** `User` atualizado

**Erros:** `404` não encontrado · `409` email duplicado · `403` tentativa de alterar usuário de perfil superior

---

### DELETE /usuarios/:id — Excluir usuário (soft-delete)

**Perfis:** `SuperAdmin`, `AdminOperacional` (condição [1])

**Response 204**

**Erros:** `404` não encontrado · `403` tentativa de excluir usuário de perfil superior · `409` usuário possui expedientes ou demandas ativas

---

### POST /usuarios/:id/pin/reset — Resetar PIN (D6, 2026-07-08)

**Perfis:** `SuperAdmin`, `AdminOperacional` (mesmo RBAC de escrita de `Usuario`)

Endpoint GENÉRICO por perfil — cobre `Empreiteiro` hoje e qualquer perfil PIN
futuro, reusando `UsuarioService.resetPin` (fonte única da credencial, Rule 4;
já tenant-safe + guarda de hierarquia + guarda "sem credencial PIN"). `:id` =
`User.id`. **Distinto** de `POST /operadores/:id/pin/reset` (T4.3), que
continua sendo o canônico para `Operador` (`:id` ali = `Operador.id`) — os
dois endpoints coexistem, cada um roteado pelo aggregate correto.

**Request:** sem body. O sistema gera o PIN.

**Response 200:**
```json
{ "pin": "654321" }
```

**Erros:** `404` usuário inexistente / cross-tenant / soft-deletado · `403 RBAC-003` non-bypass sem contexto de obra · `409 USR-002` hierarquia · `409 USR-005` usuário sem credencial PIN (ex.: perfil senha) · `401/403` guards globais.

**Auditoria:** este endpoint grava um evento `PIN_RESET` em `AuthAuditLog`
(decisão Paulo, 2026-07-08) — mesma paridade de segurança de
`POST /operadores/:id/pin/reset` (T4.3), agora implementada diretamente em
`UsuarioService.resetPinGerado` (o endpoint É genérico por perfil, sem uma
camada de use-case equivalente por aggregate). Registra `userId` do alvo,
`perfil` do alvo, `endpoint`, `ip`/`user-agent` da request e `actorUserId`/
`actorPerfil` no `metadata` — **nunca** o PIN em claro nem o hash. Só audita
em sucesso.

---

## 5. Obras e recursos espaciais (`/obras`)

### CRUD de Obra (`POST` / `GET` lista / `PATCH` / `DELETE` /obras)

**Perfis:** `SUPER_ADMIN` (escrita); `GET /obras` (lista) leitura de shell/contexto. Amendment 2026-07-18 (Regra 15) — endpoints existiam em `obras.controller.ts` sem seção própria em `SPEC/08`.

| Método | Rota | Perfis | Nota |
|--------|------|--------|------|
| `POST` | `/obras` | `SUPER_ADMIN` | cria obra (cadastro FGR-Ops) |
| `GET` | `/obras` | shell (SuperAdmin/Board cross-tenant) | listagem de obras |
| `PATCH` | `/obras/:id` | `SUPER_ADMIN` | atualização de dados da obra (distinto de `/configuracoes`, que é expediente e aceita `ADMIN_OPERACIONAL` — DEC-050) |
| `DELETE` | `/obras/:id` | `SUPER_ADMIN` | soft-delete |

---

### GET /obras/:id — Detalhe de obra

**Response 200:** obra com `setoresOperacionais[]`, `expedienteInicio`, `expedienteFim`. Os 4 campos completos de expediente (`+ limiteHoraExtraMin`, `+ diasAtivos`) e sua edição vivem em `GET/PATCH /obras/:id/configuracoes` (amendment 2026-07-16 — DEC-050) — este endpoint não foi estendido nesta amenda.

---

### GET /obras/:obraId/prontidao — Checklist de prontidão da obra

**Rastreio PRD:** `REQ-FUNC-009`

**Perfis (`PRONTIDAO_READ_PERFIS`):** `SUPER_ADMIN`, `BOARD`, `ADMIN_OPERACIONAL`, `TOWER_OPERATOR`. `USUARIO_INTERNO_FGR` **fora** (não opera a fila). Fonte única compartilhada BE/FE (`packages/types/src/perfis.ts`) — o FE gateia o fetch por este set para evitar `403` previsível. Contrato original em `DEC-046`; alargamento a `TOWER_OPERATOR` em `DEC-052`.

**Tenant:** o `obraId` do **path** é a fonte autoritativa (`ObraResolver`, `404 TEN-001` para outra obra). `SUPER_ADMIN`/`BOARD` fazem bypass do filtro de tenant (o overview da shell consulta várias obras — uma chamada por obra); o header `X-Tenant-Obra-Id` **não** é injetado em `/obras/*`.

**Response 200 (`ProntidaoObra`):**
```json
{
  "pronta": true,
  "requisitos": [
    { "chave": "setorOperacional",  "ok": true },
    { "chave": "quadra",            "ok": true },
    { "chave": "lote",              "ok": true },
    { "chave": "tipoMaquinario",    "ok": true },
    { "chave": "servico",           "ok": true },
    { "chave": "maquinarioAtivo",   "ok": true },
    { "chave": "operadorHabilitado","ok": true }
  ]
}
```

7 critérios persistíveis (`DEC 2026-06-22`; critério #18 de params operacionais adiado — sem persistência). `pronta = requisitos.every(r => r.ok)`. `tipoMaquinario`/`servico` contam catálogos **globais** (sem `obraId`); `maquinarioAtivo` = máquinas da obra não soft-deletadas; `operadorHabilitado` = operadores da obra com ≥1 tipo de maquinário autorizado. Read-side ML-owned (ADR 0002); Transaction Script (não há aggregate de prontidão).

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

### DELETE /obras/:id/setores/:setorId — Excluir setor operacional (hard-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `404 TEN-001` setor não encontrado · `409 REC-002` setor possui quadras ou locais externos vinculados (hard-delete bloqueado por dependências — ADR 2026-05-21, DEC-045)

---

### GET /obras/:id/ruas — Listar ruas

**Perfis:** todos (leitura de contexto)

**Query params:** `?page=&limit=`

**Response 200:** lista paginada de `Rua` com itens enxutos `{ id, nome }`, ordenada por `nome` asc:
```json
{
  "data": [{ "id": "uuid", "nome": "string" }],
  "total": 0,
  "page": 1,
  "limit": 20
}
```

> Coleção espacial unbounded → envelope paginado `{data,total,page,limit}` (Regra 19 / DEC-045), distinto do array puro de `setores`.

---

### POST /obras/:id/ruas — Criar rua

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (CreateRuaDto):**
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
  "obraId": "uuid",
  "criadoEm": "ISO-8601",
  "atualizadoEm": "ISO-8601"
}
```

**Erros:** `400` `nome` ausente/inválido · `409 REC-001` nome duplicado na mesma obra (unique `UX_Rua_obraId_nome`)

---

### GET /obras/:id/ruas/:ruaId — Detalhe de rua

**Perfis:** todos (leitura de contexto)

**Response 200:** `Rua` (shape completo `{ id, nome, obraId, criadoEm, atualizadoEm }`)

**Erros:** `404 TEN-001` rua não encontrada ou fora do tenant

---

### PATCH /obras/:id/ruas/:ruaId — Atualizar rua

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateRuaDto):** `{ "nome"?: "string" }` — body vazio → `400`

**Response 200:** `Rua` atualizada (shape completo)

**Erros:** `400` body vazio · `404 TEN-001` rua não encontrada · `409 REC-001` nome duplicado

---

### DELETE /obras/:id/ruas/:ruaId — Excluir rua (hard-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `404 TEN-001` rua não encontrada · `409 REC-002` rua possui quadras vinculadas (guard por contagem de dependentes + fallback FK `P2003` na janela TOCTOU)

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

**Erros:** `400` campos obrigatórios ausentes · `404 TEN-001` `setorOperacionalId` ou `ruaId` não encontrado na obra · `409 REC-001` código duplicado na mesma obra

---

### PATCH /obras/:id/quadras/:quadraId — Atualizar quadra

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateQuadraDto):** campos parciais de `CreateQuadraDto`

**Response 200:** `Quadra` atualizada

**Erros:** `404 TEN-001` quadra não encontrada · `409 REC-001` código duplicado · `422` `setorOperacionalId`/`ruaId` de obra diferente

> **Assimetria 404 (create) × 422 (patch) — deliberada, DEC-045.** No `POST`, FK fora da obra → `404 TEN-001` (recurso do tenant inexistente). No `PATCH`, a checagem TOCTOU da FK cross-obra retorna `422 UNPROCESSABLE_ENTITY` **sem código de domínio §8** (espelha o precedente do check-in de Operador, §4). **Item em aberto (decisão de Paulo):** normalizar ambos para `404 TEN-001` removendo a assimetria? Até decidir, o MVP honra este contrato (422 no patch).

---

### DELETE /obras/:id/quadras/:quadraId — Excluir quadra (hard-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `404 TEN-001` quadra não encontrada · `409 REC-002` quadra possui lotes vinculados ou demandas ativas (hard-delete bloqueado por dependências — ADR 2026-05-21, DEC-045)

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

**Erros:** `400` campos obrigatórios ausentes · `404 TEN-001` `quadraId` não encontrado na obra · `409 REC-001` código duplicado na mesma quadra

---

### PATCH /obras/:id/quadras/:quadraId/lotes/:loteId — Atualizar lote

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateLoteDto):** campos parciais de `CreateLoteDto`

**Response 200:** `Lote` atualizado

**Erros:** `404 TEN-001` lote não encontrado · `409 REC-001` código duplicado

---

### DELETE /obras/:id/quadras/:quadraId/lotes/:loteId — Excluir lote (hard-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `404 TEN-001` lote não encontrado · `409 REC-002` lote possui dependências ativas e não pode ser excluído (hard-delete bloqueado por dependências — ADR 2026-05-21, DEC-045)

---

> ⏸️ **Adjacências de lote — adiadas para pós-MVP (DEC-045 / design D1).** O modelo `LoteAdjacencia` está marcado `@deprecated` (comment-only — sem CRUD, sem drop). Os três endpoints abaixo (`GET`/`POST`/`DELETE` `.../adjacencias`) **não foram implementados na T9.1** e ficam como parking-lot. O auto-allocator do MVP usa *least-loaded* (sem adjacency scoring). Os códigos `REC-003`/`REC-004` (§8) permanecem reservados para quando a adjacência for retomada. A especificação a seguir é o contrato-alvo, não o estado atual.

### GET /obras/:id/quadras/:quadraId/lotes/:loteId/adjacencias — Listar adjacências do lote _(pós-MVP — não implementado)_

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
  "tipo": "string livre (obrigatório, máx. 100 — NÃO é enum; ex. ilustrativos: PORTARIA, PULMAO, GARAGEM, OUTRO; espelha Servico.categoria, sem CHECK; DEC-045/T9.2)",
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

**Erros:** `400` campos obrigatórios ausentes · `404 TEN-001` `setorOperacionalId` não encontrado na obra (DEC-015) · `409 REC-001` nome duplicado **na obra** (`@@unique([obraId,nome])` → `UX_LocalExterno_obraId_nome`; **não** "no mesmo setor" — DEC-045/T9.2)

---

### PATCH /obras/:id/locais-externos/:localExternoId — Atualizar local externo

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Request (UpdateLocalExternoDto):** campos parciais de `CreateLocalExternoDto`

**Response 200:** `LocalExterno` atualizado

**Erros:** `400` corpo vazio (informe ao menos um campo) · `404 TEN-001` local externo não encontrado · `409 REC-001` nome duplicado na obra · `422` `setorOperacionalId` de obra diferente (`UNPROCESSABLE_ENTITY` sem código §8 — assimetria DEC-015: create→404 / patch→422)

---

### DELETE /obras/:id/locais-externos/:localExternoId — Excluir local externo (hard-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`

**Response 204**

**Erros:** `409 REC-002` local externo possui demandas vinculadas (hard-delete bloqueado por dependências — `LocalExterno` não tem `deletadoEm`; guard por `_count.demandas` + fallback FK `P2003` na janela TOCTOU — ADR 2026-05-21, DEC-045/T9.2)

---

> **⚠️ Cadastro de Ajudante — fora do MVP-15jul, adiado p/ Fase 2 (DEC-041, REQ-FUNC-004).** Tabelas Prisma mantidas como parking-lot; contratos abaixo são referência pós-MVP.

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

### Catálogo de materiais (`/obras/:id/materiais` — GET/POST/PATCH/DELETE) _(pós-MVP — não implementado)_

> ⚠️ **Não implementado no MVP-15jul.** Não existe `materiais.controller.ts` em `apps/api` (verificado 2026-07-18). Por `DEC-055`, material no MVP é **texto livre** (`Demanda.materialTexto`), não catálogo estruturado — o catálogo (dropdown que alimenta `fator_material`/`W_mat`) é pós-MVP, junto do motor de priorização (`DEC-024`). Toda esta subseção é mantida como contrato de roadmap.

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

> ⚠️ Fora do MVP-15jul — substituído por `GET /demandas/kanban` (DEC
> `2026-07-07-kanban-endpoint-unico-rbac-ampliado`). Contrato abaixo é referência
> pré-pivot (score/SLA/WebSocket), não implementado.

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

### GET /obras/:id/configuracoes — Ler configurações de expediente da obra (amendment 2026-07-16 — DEC-050)

**Rastreio PRD:** `REQ-FUNC-004`

**Perfis:** `AdminOperacional`, `SuperAdmin`

> **Novo endpoint** (T1, `ObrasController.getConfiguracoes`) — não existia antes desta amenda. Mesma shape/perfis do `PATCH` abaixo; leitura pura, sem side-effects.

**Response 200 (`ObraConfiguracoesDto`):**
```json
{
  "obraId": "uuid",
  "expedienteInicio": "HH:MM | null",
  "expedienteFim": "HH:MM | null",
  "limiteHoraExtraMin": "number (0–1439) | null",
  "diasAtivos": "number[] (ISO 1–7, sem duplicatas) | null"
}
```

**Erros:** `404` obra não encontrada no tenant · `401/403`

---

### PATCH /obras/:id/configuracoes — Atualizar configurações de expediente da obra

**Rastreio PRD:** `REQ-FUNC-004`

**Perfis:** `AdminOperacional`, `SuperAdmin`

> **Amendment 2026-07-16 (DEC-050 — Task 18, `REQ-FUNC-004`):** este endpoint passou a governar **só** o expediente da obra. Os campos `pesoAdjacencia`/`pesoServico`/`pesoMaterial` documentados aqui numa versão anterior **nunca foram implementados neste endpoint** e foram removidos da prosa — os pesos de fila (`W_adj`/`W_srv`/`W_mat`, default 50/30/20) permanecem **fixos** no motor de score (adjacency **fora do MVP**; o auto-allocator do MVP é *least-loaded*, sem scoring de adjacência — [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md)); configurá-los via API é **pós-MVP** (ver `docs/audit/decisions-log.md` DEC-050).

**Request (`ObraConfiguracoesReqDto` / `obraConfiguracoesSchema`, `.strict()`):**
```json
{
  "expedienteInicio": "HH:MM | null",
  "expedienteFim": "HH:MM | null",
  "limiteHoraExtraMin": "number inteiro, 0–1439 | null",
  "diasAtivos": "number[] (ISO 1–7, 1 a 7 itens, sem duplicatas) | null"
}
```

> **Tudo-ou-nada (os 4 campos sempre presentes no body):** os 4 campos devem ser todos `null` (desliga o controle de expediente da obra) ou todos preenchidos (liga) — **não há mais "campos omitidos mantêm o valor atual"** para expediente; enviar um subconjunto não-nulo é erro. `HH:MM` valida contra `^([01]\d|2[0-3]):[0-5]\d$`. Validação de negócio (`JanelaExpediente.create`, `packages/domain/src/core/obra/janela-expediente.ts`) roda só quando os 4 campos vêm preenchidos.

**Response 200 (`ObraConfiguracoesDto`):** mesma shape do `GET` acima.

**Erros:**
- `422` **sem código de erro próprio** (só `message` — precedente do `422` de FK cross-obra em Quadra/LocalExterno, §5) para:
  - subconjunto não-nulo (nem todos `null`, nem todos preenchidos) — _"Configuração de expediente é tudo-ou-nada: preencha os 4 campos ou envie todos null"_
  - `expedienteInicio >= expedienteFim`
  - `expedienteFim + limiteHoraExtraMin` cruza a meia-noite (`>= 24:00`)
  - `diasAtivos` vazio, com duplicata ou fora de `1..7`
- `404` obra não encontrada no tenant · `400` payload malformado (regex `HH:MM`, tipo) · `401/403`

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

**Response 200:** lista de `TipoMaquinario` com `id`, `nome`, `descricao`, `criadoEm`, `atualizadoEm` — array puro, sem paginação (catálogo bounded). Sem relações aninhadas: `servicos[]` não é retornado (o `SELECT` é escalares-apenas; a associação Servico↔TipoMaquinario será exposta pelo endpoint de serviços quando o catálogo entrar — regra 15, código vence)

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

### GET /servicos — Catálogo de serviços (GLOBAL)

> **Divergência SPEC↔código (Rule 15, código canônico — T8.2/T8.3).** `Servico` é
> catálogo **global** (sem `obraId`/`deletadoEm`, igual `TipoMaquinario`): rota
> global `/servicos` (não aninhada em `/obras/:id`), **hard-delete** (não
> soft-delete), campo `prioridade` (não `prioridadeBase`), `+ categoria`,
> response embeda `tiposMaquinario [{id,nome}]`. Precedente: `/tipos-maquinario`.
>
> **MVP (Slice 9, T9.x — REQ-FUNC-003/REQ-FUNC-002) — Serviço⇄TipoMaquinario N:M.**
> Cardinalidade deixou de ser 1:N (`Servico.tipoMaquinarioId`) e virou N:M via junction
> explícita `ServicoTipoMaquinario` (espelho de `OperadorTipoMaquinario`). O embed
> singular `tipoMaquinario {id,nome}` foi **substituído** por `tiposMaquinario: [{id,nome}]`
> (array, ordenado por `nome` asc). Unicidade de `Servico.nome` deixou de ser composta
> com `tipoMaquinarioId` e virou **global** (índice `UX_Servico_nome`) — nome duplicado
> em qualquer tipo → `409 REC-001`. Migração fundiu serviços duplicados por nome
> (canônico = menor `criadoEm`, desempate por `id`; DEC `2026-07-05-servico-tipo-maquinario-nm`).

**Perfis:** qualquer autenticado (leitura aberta).

**Response 200:** array puro de `Servico` com `id`, `nome`, `descricao`,
`prioridade`, `exigeTransporte`, `categoria`, `tiposMaquinario: [{ id, nome }]`
(ordenado por `nome` asc), `criadoEm`, `atualizadoEm` (sem paginação — carve-out
de cardinalidade Q3/PERF-002).

---

### GET /servicos/:id

**Response 200:** `Servico` · **Erros:** `404` `TEN-001` serviço não encontrado.

---

### POST /servicos — Criar serviço

**Perfis:** `AdminOperacional`, `SuperAdmin` (`CATALOGO_WRITE_PERFIS`).

**Request (CreateServicoDto):**
```json
{
  "nome": "string (obrigatório, 1..255)",
  "descricao": "string (opcional)",
  "prioridade": "NORMAL | ELEVADA | MAXIMA (obrigatório)",
  "exigeTransporte": "boolean (opcional, padrão false)",
  "categoria": "MOVIMENTACAO | OUTRO (opcional, padrão OUTRO)",
  "tiposMaquinarioIds": "string[] (obrigatório, mín. 1 — dedupe no parse)"
}
```

> **MVP (Slice 9) — `tipoMaquinarioId` → `tiposMaquinarioIds`.** Campo singular
> substituído por array (mín. 1 elemento, deduplicado no Zod). Cada id deve existir
> no catálogo `TipoMaquinario`; id inexistente → `404 TEN-001`.

**Response 201:** `Servico` criado (shape do `GET /servicos`, com `tiposMaquinario` embed).

**Erros:** `400` validação DTO · `404` `TEN-001` algum id de `tiposMaquinarioIds` não encontrado ·
`409` `REC-001` já existe serviço com este nome (unicidade **global**, ver nota acima em GET /servicos).

---

### PATCH /servicos/:servicoId — Atualizar serviço

**Perfis:** `AdminOperacional`, `SuperAdmin`.

**Request (UpdateServicoDto):** campos parciais de `CreateServicoDto`, incluindo
`tiposMaquinarioIds` (string[], mín. 1 quando enviado). **Substituição completa do
conjunto** — não é merge/patch incremental: o array enviado passa a ser o novo set
de tipos vinculados ao serviço (delete-then-insert na junction `ServicoTipoMaquinario`).
Corpo vazio → `400`. `descricao` aceita `null` para **limpar** a descrição
(FEUX-002 — paridade com `maquinario.placa`; T8.3): string vazia é rejeitada
(`400`, usar `null`), campo omitido = no-touch.

**Response 200:** `Servico` atualizado.

**Erros:** `400` validação / corpo vazio · `404` `TEN-001` serviço não encontrado
ou algum id de `tiposMaquinarioIds` não encontrado · `409` `REC-001` nome duplicado
(unicidade global).

---

### DELETE /servicos/:servicoId — Excluir serviço (HARD-delete)

**Perfis:** `AdminOperacional`, `SuperAdmin`.

**Response 204**

**Erros:** `404` `TEN-001` serviço não encontrado · `409` `REC-002` serviço possui
demandas vinculadas (não pode ser excluído).

---

## 6. Empreiteiras (`/empreiteiras`)

**Rastreio PRD:** `REQ-FUNC-012`

`Empreiteira` é entidade de catálogo **GLOBAL** (sem `obraId`, DEC-016) — mesmo
padrão de `TipoMaquinario`/`Servico`. **Divergência deliberada da versão
anterior desta seção** (D3, decisão 2026-07-08): o texto original fazia
`AdminOperacional` ver só empreiteiras que já tinham um `Empreiteiro` vinculado
à obra dele, o que criava um deadlock — uma empreiteira recém-cadastrada nunca
apareceria no dropdown de vínculo do primeiro usuário `Empreiteiro`. A leitura
é agora **global e sem filtro de tenant para todo perfil autorizado** — não há
mais uso de `X-Tenant-Obra-Id` neste endpoint. Ver
`memory/decisions/2026-07-08-empreiteira-leitura-global-sem-filtro-obra.md`.

---

### GET /empreiteiras — Listar empreiteiras

**Perfis:** `SuperAdmin`, `Board` (read-only), `AdminOperacional`, `UsuarioInternoFGR` (read-only) — leitura GLOBAL, sem filtro de obra (D3). `TowerOperator`/`Operador`/`Empreiteiro` NÃO leem este catálogo.

**Query params:** `?search=&page=&limit=`

**Response 200:** lista paginada `{ data, total, page, limit }` com `id`, `nome`, `cnpj`, `telefone`, `email`, `responsavel`, `endereco`, `ativo`

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

**Response 201:** `Empreiteira` criada com todos os campos (mesmo shape do GET — `id`, `nome`, `cnpj`, `telefone`, `email`, `responsavel`, `endereco`, `ativo`)

**Erros:** `400` campos obrigatórios ausentes · `409` CNPJ já cadastrado globalmente

---

### GET /empreiteiras/:id — Detalhe de empreiteira

**Perfis:** `SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR` — mesmo conjunto da listagem (D3). **Divergência:** o carve-out anterior ("Empreiteiro própria empreiteira") foi removido — `Empreiteiro` não tem hoje nenhum caso de uso de leitura direta deste catálogo; se necessário no futuro, é um endpoint/escopo novo, não uma reabertura deste.

**Response 200:** `Empreiteira` completa com todos os campos

**Erros:** `404` não encontrada

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
| `DEM-005` | Demanda | Inconsistência transporte/destino (bidirecional) — destino ausente quando `exigeTransporte=true` · OU destino/`transporteInterno` enviados a serviço que não exige transporte · OU `transporteInterno=true` com destino explícito (422) |
| `DEM-006` | Demanda | Serviço (`servicoId`) não encontrado no catálogo global — `POST /demandas` (404) |
| `DEM-007` | Demanda | Material obrigatório ausente para serviço de movimentação (`categoria=MOVIMENTACAO`) — T8.4 (400) |
| `DEM-008` | Demanda | Material informado não se aplica ao serviço (`categoria≠MOVIMENTACAO`) — T8.4 (400) |
| `DEM-009` | Demanda | Local (quadra/lote/localExterno de origem ou destino) não encontrado na obra/quadra — `POST /demandas` (404) |
| `DEM-010` | Demanda | Tipo de maquinário não compatível com o serviço — `POST /demandas` (422) |
| `DEM-011` | Demanda | Reorder: `aposDemandaId` fora da fila PENDENTE da obra ou igual à própria demanda — `POST /demandas/:id/reordenar` (422) |
| `DEM-012` | Demanda | Reorder: fila precisa de rebalanceamento (chave >64 chars ou par duplicado) — `POST /demandas/:id/reordenar` (422) |
| `DEM-013` | Demanda | Operador não habilitado no tipo de maquinário da demanda — `POST /demandas` (gestão) e `POST /demandas/:id/alocar` (422) |
| `OPR-001` | Operador | Sem expediente ativo para esta ação |
| `OPR-002` | Operador | Operador fora do setor da demanda (aviso — não bloqueio em alocação manual) |
| `OPR-003` | Operador | Check-in duplicado no mesmo turno |
| `OPR-004` | Operador | Checkout sem expediente ativo |
| `OPR-005` | Operador | ~~Checkout bloqueado~~ — **Supersedido por DEC-025**: demandas em `EM_ANDAMENTO`/`PAUSADA` são devolvidas automaticamente no checkout (`devolver_fim_expediente`, ator SISTEMA); código reservado para referência histórica |
| `OPR-006` | Operador | Ajudante já é o ajudante ativo do turno (fora do MVP-15jul — Fase 2, DEC-041) |
| `OPR-007` | Operador | Ajudante em turno ativo com outro operador (fora do MVP-15jul — Fase 2, DEC-041) |
| `OPR-008` | Operador | TipoMaquinario informado não existe (cadastro de operador, `POST/PATCH /operadores`) — T4.2 (404) |
| `OPR-009` | Operador | Operador já existe para este User (backstop `Operador.userId @unique`) — T4.2 (409) |
| `OPR-010` | Operador | `obraId` ausente no body de `POST /operadores` sob `SuperAdmin` (bypass de tenant; `Operador.obraId` é NOT NULL) — T4.2 (400) |
| `OPR-011` | Operador | Máquina não liberada para este operador — check-in bloqueado (sem linha em `OperadorMaquinario`, ADR 0004) — `POST /expediente/checkin` (403) |
| `OPR-012` | Operador | Máquina fora dos tipos habilitados — violação da cascata tipo→máquina (ADR 0004) — `POST/PATCH /operadores` (422) |
| `OPR-013` | Operador | Check-in fora do expediente da obra sem `confirmarForaDaJanela` (amendment 2026-07-16, DEC-050) — `POST /expediente/checkin` (422) |
| `REC-001` | Recurso espacial | Nome/código duplicado na mesma obra |
| `REC-002` | Recurso espacial | Recurso possui dependências ativas (não pode ser excluído) |
| `REC-003` | Recurso espacial | Adjacência já existente — _reservado, pós-MVP (adjacência adiada, DEC-045 / D1)_ |
| `REC-004` | Recurso espacial | Lote destino é o próprio lote origem — _reservado, pós-MVP (adjacência adiada, DEC-045 / D1)_ |
| `USR-001` | Usuário | Email duplicado |
| `USR-002` | Usuário | Perfil hierárquico superior ao do solicitante |
| `USR-003` | Usuário | `empreiteiraId` inválido para o perfil informado |
| `USR-004` | Usuário | CPF já cadastrado para outro usuário ativo (índice filtrado `UX_User_cpf_active`) — DEC-042 |
| `AUTH-001` | Autenticação | Credenciais inválidas (mensagem genérica) |
| `AUTH-002` | Autenticação | Token expirado |
| `AUTH-003` | Autenticação | Perfil sem permissão (RBAC) |
| `AUTH-004` | Autenticação | Rate limit excedido |
| `TEN-001` | Multi-tenant | Recurso não pertence ao tenant da obra |

---

## 9. Rate limiting — resumo

Dois buckets globais (Redis): `auth` (env `RATE_LIMIT_AUTH_MAX`, default 5/min)
vale **somente** nas rotas de credencial com opt-in `@AuthRateLimit()` (DEC
`2026-07-07-throttler-auth-bucket-blanketa-demandas`); `default` (env
`RATE_LIMIT_DEMANDA_MAX`, default 20/min) governa **todas** as demais rotas.

| Endpoint | Limite | Janela | Bloqueio |
|----------|--------|--------|----------|
| `POST /auth/login` | 5 req por IP (bucket `auth`) | 1 min | Lockout 15 min por usuário |
| `POST /auth/pin` | 30 req por IP (override de rota; DEC 2026-05-29) | 1 min | Lockout progressivo por usuário: 1/5/15 min |
| Demais rotas (incl. `/auth/refresh`, `/auth/logout`, `/demandas/*`, catálogos) | 20 req (bucket `default`) | 1 min | — |

Violações retornam `HTTP 429` com header `Retry-After` (segundos até desbloqueio).
O lockout (por usuário, camada de domínio) é mecanismo distinto do throttler
(por IP, guard global) — os dois coexistem em login/pin.

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
