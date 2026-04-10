# Definições complementares

**Rastreio PRD:** `REQ-NFR-002`, `REQ-NFR-004`, `REQ-FUNC-004`, `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-009`, `REQ-ACE-005`, `REQ-RISK-002`, `REQ-MET-002`, `REQ-MET-003`

Este módulo fecha lacunas operacionais do MVP com decisões técnicas complementares sobre offline, agendamento, exclusão mútua adiada e rastreabilidade de ajudantes.

## Estratégia PWA offline {#estrategia-pwa-offline}

A conectividade instável nos canteiros exige que a interface de campo opere com `Service Workers`, persistência local e sincronização posterior de forma assimétrica.

### Classificação das operações de frontend

- **Visualizar fila**: `offline-capable`, consumindo cache local preordenado sem bloquear a UI se o polling falhar.
- **Iniciar demanda**: `offline-queue`, com persistência local de `iniciadoEm` e envio posterior.
- **Concluir demanda**: `offline-queue`, com persistência local de `finalizadoEm` e sincronização silenciosa.
- **Trocar ajudante**: `offline-queue`, com registro pontual no buffer local.
- **Check-in / Encerrar expediente**: `online-only`, porque alteram a posse transacional da máquina e do turno.

### Resolução de conflitos

- **Conclusão concorrente**: se o operador concluir offline e um admin reatribuir online, prevalece o evento de campo (`Last-Write-Wins` sobre `finalizadoEm`), cancelando a realocação posterior.
- **Início vs cancelamento**: se uma demanda for iniciada offline e cancelada online em simultâneo, prevalece o início em campo (`Last-Write-Wins` sobre `iniciadoEm`).
- **Troca de ajudante vs encerramento**: eventos de troca de ajudante com timestamp posterior ao encerramento do expediente são descartados com log de aviso.

### Feedback visual e armazenamento local

- A UI deve exibir banner fixo ao perder conectividade.
- Um sync widget deve mostrar o tamanho da `offline-queue` pendente.
- Dados não cacheáveis: tokens JWT expirados, `DemandaLog` completo e qualquer demanda fora do escopo do operador.

| Recurso | Estratégia | TTL de cache | Sincronização |
| :--- | :--- | :--- | :--- |
| Fila de demandas do operador | Cache First | 4 horas | Background Fetch / Sync Event / Invalidação por evento |
| Catálogo de tipos e serviços | Cache API com fallback de rede | 7 dias | Revalidação no login diário |
| Payloads transacionais | Offline Queue (`IndexedDB`) | Indeterminado | Sync imediato em reidratação de rede (`FIFO`) |
| Expedientes de outros dias | Network Only | 0 | Sem cache local |

### Invalidação por evento

O sistema deve usar `WebSockets` ou `Server-Sent Events` como fallback para emitir sinais de `INVALIDATE_QUEUE`. O `Service Worker` marca o cache da fila como stale e força novo fetch na próxima renderização ou background sync.

Nota de implementação: o armazenamento estruturado no contexto do `Service Worker` deve usar exclusivamente `IndexedDB` ou `Cache API`. `localStorage` não pode ser usado como base para dados offline do worker.

## Mecanismo de notificação em tempo real {#mecanismo-notificacao-realtime}

O FGR-OPS MVP utiliza **WebSocket** como canal único de comunicação em tempo real entre o backend (NestJS Gateway) e o PWA. Não há suporte a notificações nativas via Web Push API no MVP — o operador deve manter o aplicativo aberto durante o expediente (DEC-017).

### Transporte e autenticação

- **Protocolo:** WebSocket (`wss://`) sobre o mesmo host do backend.
- **Endpoint:** `wss://<host>/ws`
- **Autenticação:** O cliente envia o JWT de acesso como parâmetro de query (`?token=<jwt>`) na abertura da conexão. O gateway valida o token e extrai `userId`, `obraId` e `perfil` antes de aceitar a conexão.
- **Escopo da conexão:** Cada conexão é scoped por `userId` + `obraId`. O servidor roteia mensagens individualmente — não há broadcast global.
- **Heartbeat:** Ping/pong a cada 30 segundos. Sem resposta em 10 s, a conexão é encerrada; o cliente reconecta com back-off exponencial (1 s → 2 s → 4 s, máximo 30 s).

### Envelope de eventos

Todos os eventos do servidor seguem o formato:

```json
{
  "type": "<EVENT_TYPE>",
  "obraId": "uuid",
  "payload": { }
}
```

### Eventos para perfil `Operador`

| Evento | Quando disparado | Destinatário |
| :--- | :--- | :--- |
| `DEMAND_QUEUED` | Nova demanda entra na fila do operador (score calculado, posição definida) | Operador destinatário |
| `INVALIDATE_QUEUE` | Qualquer alteração que invalide o cache local da fila (nova demanda, recálculo, conclusão por outro) | Todos os operadores ativos da obra |
| `SLA_ALERT` | Vencimento do SLA de uma demanda pendente — disparado **uma única vez** no instante `slaVencimentoEm` | Operador vinculado à demanda |

**Payload `DEMAND_QUEUED`:**

```json
{
  "demandaId": "uuid",
  "prioridade": "MAXIMA | ELEVADA | NORMAL",
  "servicoNome": "string",
  "localDescricao": "string",
  "score": 0.0,
  "posicaoFila": 1,
  "criadaEm": "ISO8601"
}
```

**Payload `SLA_ALERT`:**

```json
{
  "demandaId": "uuid",
  "prioridade": "MAXIMA | ELEVADA",
  "slaVencimentoEm": "ISO8601",
  "operadorId": "uuid"
}
```

**Payload `INVALIDATE_QUEUE`:**

```json
{
  "motivo": "NOVA_DEMANDA | SCORE_RECALCULADO | DEMANDA_CONCLUIDA | REATRIBUICAO"
}
```

### Eventos para perfis `AdminOperacional`, `UsuarioInternoFGR`, `SuperAdmin`

| Evento | Quando disparado | Destinatário |
| :--- | :--- | :--- |
| `SLA_ESCALATION` | Escalação após +5 min sem ação (`MAXIMA`) ou +15 min (`ELEVADA`) | Admins + SuperAdmin da obra |
| `DEMAND_STATUS_CHANGED` | Qualquer transição de estado de demanda | Admins com painel Kanban aberto |
| `INVALIDATE_QUEUE` | Mesma regra dos operadores | Admins com painel Kanban aberto |

**Payload `SLA_ESCALATION`:**

```json
{
  "demandaId": "uuid",
  "prioridade": "MAXIMA | ELEVADA",
  "slaVencimentoEm": "ISO8601",
  "operadorId": "uuid",
  "escaladoAposSegundos": 300
}
```

**Payload `DEMAND_STATUS_CHANGED`:**

```json
{
  "demandaId": "uuid",
  "statusAnterior": "string",
  "statusNovo": "string",
  "atorId": "uuid",
  "timestamp": "ISO8601"
}
```

### Regras de deduplicação e estado visual

- O evento `SLA_ALERT` é disparado **uma única vez** por demanda no instante `slaVencimentoEm`. O estado visual de "SLA vencido" na UI persiste até a demanda transitar para `EM_ANDAMENTO`, `CONCLUIDA` ou `CANCELADA`.
- `DEMAND_QUEUED` com `prioridade = MAXIMA` deve acionar vibração no dispositivo via API Vibration do PWA (padrão `[200, 100, 200]`), além do destaque visual obrigatório definido em [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score).
- `SLA_ESCALATION` não é deduplicado — cada etapa de escalação gera um evento distinto.
- `DEMAND_STATUS_CHANGED` é sempre emitido, independentemente de quem realizou a ação (operador, admin ou sistema).

### Degradação graceful

Se a conexão WebSocket for perdida:

- A UI exibe o banner fixo de "Conexão perdida" (mesmo mecanismo da estratégia offline descrita acima).
- Operações críticas (`iniciar`, `concluir`) entram na `offline-queue` conforme documentado na seção anterior.
- A fila local permanece visível via cache, marcada como "pode estar desatualizada".
- Ao reconectar, o cliente re-autentica e solicita `GET /operadores/:id/fila` para reidratar o estado antes de processar novos eventos.

> **Rastreio PRD:** `REQ-NFR-002`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-ACE-005`. Decisão: DEC-017.

---

## Comportamento de `dataAgendada` {#comportamento-de-dataagendada}

A `Demanda.dataAgendada` deve permanecer isolada do pipeline de score em tempo real para não interferir na ordenação das demandas imediatas.

- Demandas com `dataAgendada` nascem em `AGENDADA` e não aparecem na UI do operador até a janela de ativação.
- O motor de score ignora demandas `AGENDADA`.
- A transição automática para `PENDENTE` ocorre exatamente 60 minutos antes do horário-alvo.
- Apenas `AdminOperacional`, `UsuarioInternoFGR` e `SuperAdmin` podem criar demandas agendadas.
- O SLA passa a considerar o horário original de `dataAgendada` como marco zero, mesmo que a demanda tenha sido antecipada para preparação logística.
- A ação administrativa `antecipar` pode converter manualmente `AGENDADA` em `PENDENTE` antes da janela automática.

## Definição de `ServicoDinamico`

`ServicoDinamico` fica oficialmente adiado para a Fase 2.

- A entidade exigiria regras maduras para exclusão mútua, sincronismo entre múltiplos maquinários e recuperação de falhas em operações acopladas.
- No MVP, o papel equivalente é atendido apenas por agrupamentos passivos via `DemandaGrupo`, sem orquestração simultânea de execução.

## Contrato analítico `REQ-MET-002` - Adoção e engajamento operacional {#contrato-analitico-req-met-002}

Este contrato operacional constitui a fonte canônica de medição para `REQ-MET-002`. O PRD define a intenção de negócio da métrica; esta seção define fórmula, denominador, regras de elegibilidade, janela temporal e evidências auditáveis (DEC-003).

### Fórmula

```
taxa_adocao = operadores_com_acao / operadores_cadastrados_quinzena
```

- **Numerador (`operadores_com_acao`)**: contagem distinta de `User.id` com perfil `OPERADOR` que realizaram pelo menos uma das seguintes ações registradas no sistema durante a janela da quinzena: check-in de expediente (`RegistroExpediente.iniciadoEm`), início de demanda (`Demanda` transitou para `EM_ANDAMENTO` pelo operador) ou conclusão de demanda (`Demanda` transitou para `CONCLUIDA` pelo operador).
- **Denominador (`operadores_cadastrados_quinzena`)**: contagem distinta de `User.id` com perfil `OPERADOR` cadastrados e ativos no sistema para a obra (`deletadoEm IS NULL`), cuja data de criação seja anterior ou igual ao último dia da quinzena. Operadores com `deletadoEm` preenchido antes do início da quinzena são excluídos (DEC-018).

### Janela temporal da quinzena

- **Quinzena 1**: dia 1 até dia 15 do mês (inclusive), com início às `00:00:00` do dia 1 e fim às `23:59:59` do dia 15.
- **Quinzena 2**: dia 16 até o último dia do mês (inclusive), com início às `00:00:00` do dia 16 e fim às `23:59:59` do último dia.
- **Timezone**: `America/Sao_Paulo` (BRT/BRST). Todos os timestamps de ação e de corte da quinzena são convertidos para este fuso antes da consolidação.

### Critérios de inclusão e exclusão

| Critério | Incluído | Excluído |
| :--- | :--- | :--- |
| Operador cadastrado e ativo no sistema na quinzena, com expediente registrado | Sim | — |
| Operador cadastrado e ativo no sistema, mas sem nenhuma ação no app | Sim (denominador) | Não (numerador) |
| Operador desligado (`deletadoEm`) antes do início da quinzena | — | Sim |
| Operador admitido durante a quinzena | Sim, a partir da data de admissão | — |
| Operador transferido de obra durante a quinzena | Contabilizado na obra de origem até a data de transferência e na obra de destino a partir dela | — |
| Operador em férias, licença ou afastamento formal durante toda a quinzena | — | Sim (requer marcação manual via soft-delete temporário ou flag dedicado — Fase 2) |

### Política de deduplicação

- Cada operador conta **uma única vez** no numerador, independentemente do número de ações realizadas na quinzena.
- A consolidação é por `User.id` e por `obraId`; se o operador atua em múltiplas obras, conta separadamente em cada obra.
- Ações originadas de sincronização offline são consideradas com o `timestamp` original do dispositivo (campo `iniciadoEm` ou `finalizadoEm`), não com o timestamp de sincronização no servidor.

### Artefato de validação

Para cada quinzena consolidada, o sistema deve gerar um artefato auditável contendo:

| Campo | Descrição |
| :--- | :--- |
| `obraId` | Identificador da obra |
| `quinzena` | Período de referência (ex.: `2026-03-01/2026-03-15`) |
| `total_cadastrados` | Denominador — operadores cadastrados e ativos no sistema para a obra na quinzena |
| `total_com_acao` | Numerador — operadores com pelo menos 1 ação |
| `taxa_adocao` | Resultado da fórmula (percentual) |
| `lista_sem_acao` | Array de `User.id` cadastrados e ativos no sistema sem nenhuma ação registrada |
| `gerado_em` | Timestamp de geração (`America/Sao_Paulo`) |

Este artefato deve ser persistido e acessível via painel administrativo para `AdminOperacional`, `UsuarioInternoFGR` e `SuperAdmin`.

## Política de rastreabilidade dos recursos operacionais (`REQ-NFR-004`)

O PRD exige rastreabilidade consistente dos recursos operacionais em modelo relacional multi-tenant. Além da auditabilidade transacional de `Demanda` (via `DemandaLog`) já documentada em [02-modelo-dados.md](02-modelo-dados.md), o MVP aplica as seguintes regras uniformes a todas as entidades operacionais relevantes:

| Entidade | Soft-delete (`deletadoEm`) | Auditoria de mutação | Campo `obraId` obrigatório |
| :--- | :--- | :--- | :--- |
| `Maquinario` | Sim | Sim — criação, edição e exclusão lógica geram registro com `userId`, `timestamp`, valores antigos/novos | Sim |
| `Ajudante` | Sim | Sim — mesmo contrato | Sim |
| `Servico` | Sim | Sim — mesmo contrato | Sim |
| `TipoMaquinario` | Sim | Sim — mesmo contrato | Não (catálogo global) |
| `Material` | Sim | Sim — mesmo contrato | Sim |
| `SetorOperacional` | Sim (com restrição de demandas ativas — ver [05-backlog-mvp-glossario.md](05-backlog-mvp-glossario.md#governanca-da-taxonomia-espacial-req-risk-001)) | Sim — mesmo contrato | Sim |
| `Quadra`, `Lote`, `Rua` | Sim (com restrição de demandas ativas) | Sim — mesmo contrato | Sim |
| `LocalExterno` | Sim (com restrição de demandas ativas) | Sim — mesmo contrato | Sim |
| `RegistroExpediente` | Não (imutável após encerramento) | Sim — criação e encerramento | Sim |

Regras transversais:
- Toda mutação relevante é registrada em tabela de auditoria dedicada (`ResourceAuditLog`) ou, quando já existente, em `DemandaLog`. O registro preserva `userId`, `entityType`, `entityId`, `obraId`, `action`, `oldValues`, `newValues` e `timestamp`.
- Entidades com `deletadoEm` preenchido permanecem consultáveis para efeitos de histórico e auditoria, mas são excluídas das listas operacionais ativas.
- A política garante que qualquer recurso operacional envolvido numa demanda pode ser rastreado desde a criação até o estado atual, assegurando a rastreabilidade consistente exigida por `REQ-NFR-004`.

## Rastreabilidade de ajudantes {#rastreabilidade-de-ajudantes}

O escopo do MVP associa ajudantes ao expediente e não diretamente a `Demanda`.

- A presença do ajudante é registrada em `TurnoAjudante`, com início e fim do recorte temporal.
- A ligação entre ajudante e demanda é inferida por interseção entre os intervalos `[iniciadoEm, finalizadoEm]` e `[inicioVinculo, fimVinculo]`.
- O painel administrativo pode expor um rastreio consultivo por turno, horas totais e lista de máquinas operadas em conjunto.
- Se a troca de ajudante ocorrer com a demanda em `EM_ANDAMENTO`, o sistema deve escrever o evento `TROCA_AJUDANTE` em `DemandaLog`.
- Esse registro também segue `offline-queue` com retentativa automática, para não perder auditabilidade em falhas de rede.
