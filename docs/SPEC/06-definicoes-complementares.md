# Definicoes complementares

**Rastreio PRD:** `REQ-NFR-002`, `REQ-NFR-004`, `REQ-FUNC-004`, `REQ-FUNC-006`, `REQ-FUNC-009`, `REQ-RISK-002`, `REQ-MET-002`, `REQ-MET-003`

Este modulo fecha lacunas operacionais do MVP com decisoes tecnicas complementares sobre offline, agendamento, exclusao mutua adiada e rastreabilidade de ajudantes.

## Estrategia PWA offline

A conectividade instavel nos canteiros exige que a interface de campo opere com `Service Workers`, persistencia local e sincronizacao posterior de forma assimetrica.

### Classificacao das operacoes de frontend

- **Visualizar fila**: `offline-capable`, consumindo cache local preordenado sem bloquear a UI se o polling falhar.
- **Iniciar demanda**: `offline-queue`, com persistencia local de `iniciadoEm` e envio posterior.
- **Concluir demanda**: `offline-queue`, com persistencia local de `finalizadoEm` e sincronizacao silenciosa.
- **Trocar ajudante**: `offline-queue`, com registo pontual no buffer local.
- **Check-in / Encerrar expediente**: `online-only`, porque alteram a posse transacional da maquina e do turno.

### Resolucao de conflitos

- **Conclusao concorrente**: se o operador concluir offline e um admin reatribuir online, prevalece o evento de campo (`Last-Write-Wins` sobre `finalizadoEm`), cancelando a realocacao posterior.
- **Inicio vs cancelamento**: se uma demanda for iniciada offline e cancelada online em simultaneo, prevalece o inicio em campo (`Last-Write-Wins` sobre `iniciadoEm`).
- **Troca de ajudante vs encerramento**: eventos de troca de ajudante com timestamp posterior ao encerramento do expediente sao descartados com log de aviso.

### Feedback visual e armazenamento local

- A UI deve exibir banner fixo ao perder conectividade.
- Um sync widget deve mostrar o tamanho da `offline-queue` pendente.
- Dados nao cacheaveis: tokens JWT expirados, `DemandaLog` completo e qualquer demanda fora do escopo do operador.

| Recurso | Estrategia | TTL de cache | Sincronizacao |
| :--- | :--- | :--- | :--- |
| Fila de demandas do operador | Cache First | 4 horas | Background Fetch / Sync Event / Invalidacao por evento |
| Catalogo de tipos e servicos | Cache API com fallback de rede | 7 dias | Revalidacao no login diario |
| Payloads transacionais | Offline Queue (`IndexedDB`) | Indeterminado | Sync imediato em reidratacao de rede (`FIFO`) |
| Expedientes de outros dias | Network Only | 0 | Sem cache local |

### Invalidacao por evento

O sistema deve usar `WebSockets` ou `Server-Sent Events` como fallback para emitir sinais de `INVALIDATE_QUEUE`. O `Service Worker` marca o cache da fila como stale e forca novo fetch na proxima renderizacao ou background sync.

Nota de implementacao: o armazenamento estruturado no contexto do `Service Worker` deve usar exclusivamente `IndexedDB` ou `Cache API`. `localStorage` nao pode ser usado como base para dados offline do worker.

## Comportamento de `dataAgendada`

A `Demanda.dataAgendada` deve permanecer isolada do pipeline de score em tempo real para nao interferir na ordenacao das demandas imediatas.

- Demandas com `dataAgendada` nascem em `AGENDADA` e nao aparecem na UI do operador ate a janela de ativacao.
- O motor de score ignora demandas `AGENDADA`.
- A transicao automatica para `PENDENTE` ocorre exatamente 60 minutos antes do horario-alvo.
- Apenas `AdminOperacional`, `UsuarioInternoFGR` e `SuperAdmin` podem criar demandas agendadas.
- O SLA passa a considerar o horario original de `dataAgendada` como marco zero, mesmo que a demanda tenha sido antecipada para preparacao logistica.
- A acao administrativa `antecipar` pode converter manualmente `AGENDADA` em `PENDENTE` antes da janela automatica.

## Definicao de `ServicoDinamico`

`ServicoDinamico` fica oficialmente adiado para a Fase 2.

- A entidade exigiria regras maduras para exclusao mutua, sincronismo entre multiplos maquinarios e recuperacao de falhas em operacoes acopladas.
- No MVP, o papel equivalente e atendido apenas por agrupamentos passivos via `DemandaGrupo`, sem orquestracao simultanea de execucao.

## Contrato analitico `REQ-MET-002` — Adocao e engajamento operacional

Este contrato operacional constitui a fonte canonica de medicao para `REQ-MET-002`. O PRD define a intencao de negocio da metrica; esta secao define formula, denominador, regras de elegibilidade, janela temporal e evidencias auditaveis (DEC-003).

### Formula

```
taxa_adocao = operadores_com_acao / operadores_ativos_folha_quinzena
```

- **Numerador (`operadores_com_acao`)**: contagem distinta de `User.id` com perfil `OPERADOR` que realizaram pelo menos uma das seguintes acoes registadas no sistema durante a janela da quinzena: check-in de expediente (`RegistroExpediente.iniciadoEm`), inicio de demanda (`Demanda` transitou para `EM_ANDAMENTO` pelo operador) ou conclusao de demanda (`Demanda` transitou para `CONCLUIDA` pelo operador).
- **Denominador (`operadores_ativos_folha_quinzena`)**: contagem distinta de `User.id` com perfil `OPERADOR` presentes na folha de pagamento da obra na quinzena de referencia, conforme integracao com o sistema de RH/folha. Operadores com `deletadoEm` preenchido antes do inicio da quinzena sao excluidos.

### Janela temporal da quinzena

- **Quinzena 1**: dia 1 ate dia 15 do mes (inclusive), com inicio as `00:00:00` do dia 1 e fim as `23:59:59` do dia 15.
- **Quinzena 2**: dia 16 ate ao ultimo dia do mes (inclusive), com inicio as `00:00:00` do dia 16 e fim as `23:59:59` do ultimo dia.
- **Timezone**: `America/Sao_Paulo` (BRT/BRST). Todos os timestamps de acao e de corte de folha sao convertidos para este fuso antes da consolidacao.

### Criterios de inclusao e exclusao

| Criterio | Incluido | Excluido |
| :--- | :--- | :--- |
| Operador ativo na folha da quinzena e com expediente registado | Sim | — |
| Operador ativo na folha mas sem nenhuma acao no app | Sim (denominador) | Nao (numerador) |
| Operador desligado (`deletadoEm`) antes do inicio da quinzena | — | Sim |
| Operador admitido durante a quinzena | Sim, a partir da data de admissao | — |
| Operador transferido de obra durante a quinzena | Contabilizado na obra de origem ate a data de transferencia e na obra de destino a partir dela | — |
| Operador em ferias, licenca ou afastamento formal durante toda a quinzena | — | Sim |

### Politica de deduplicacao

- Cada operador conta **uma unica vez** no numerador, independentemente do numero de acoes realizadas na quinzena.
- A consolidacao e por `User.id` e por `obraId`; se o operador atua em multiplas obras, conta separadamente em cada obra.
- Acoes originadas de sincronizacao offline sao consideradas com o `timestamp` original do dispositivo (campo `iniciadoEm` ou `finalizadoEm`), nao com o timestamp de sincronizacao no servidor.

### Fonte do denominador e integracao

A lista de operadores ativos na folha da quinzena deve ser obtida por integracao com o sistema de RH/folha da FGR. O contrato de integracao minimo exige:

- **Endpoint ou carga batch**: API REST ou importacao periodica (CSV/JSON) com frequencia minima quinzenal.
- **Payload minimo por operador**: `identificador_folha`, `User.id` (correspondencia), `obraId`, `data_admissao`, `data_desligamento` (se aplicavel), `status_folha` (ativo, ferias, licenca, afastado).
- **Reconciliacao**: o sistema deve executar reconciliacao automatica no primeiro dia util apos o fechamento de cada quinzena, gerando log de divergencias entre a base de operadores do FGR-OPS e a folha recebida.

### Artefato de validacao

Para cada quinzena consolidada, o sistema deve gerar um artefato auditavel contendo:

| Campo | Descricao |
| :--- | :--- |
| `obraId` | Identificador da obra |
| `quinzena` | Periodo de referencia (ex.: `2026-03-01/2026-03-15`) |
| `total_folha` | Denominador — operadores ativos na folha |
| `total_com_acao` | Numerador — operadores com pelo menos 1 acao |
| `taxa_adocao` | Resultado da formula (percentual) |
| `lista_sem_acao` | Array de `User.id` presentes na folha sem nenhuma acao registada |
| `gerado_em` | Timestamp de geracao (`America/Sao_Paulo`) |

Este artefato deve ser persistido e acessivel via painel administrativo para `AdminOperacional`, `UsuarioInternoFGR` e `SuperAdmin`.

## Politica de rastreabilidade dos recursos operacionais (`REQ-NFR-004`)

O PRD exige rastreabilidade consistente dos recursos operacionais em modelo relacional multi-tenant. Alem da auditabilidade transacional de `Demanda` (via `DemandaLog`) ja documentada em [02-modelo-dados.md](02-modelo-dados.md), o MVP aplica as seguintes regras uniformes a todas as entidades operacionais relevantes:

| Entidade | Soft-delete (`deletadoEm`) | Auditoria de mutacao | Campo `obraId` obrigatorio |
| :--- | :--- | :--- | :--- |
| `Maquinario` | Sim | Sim — criacao, edicao e exclusao logica geram registo com `userId`, `timestamp`, valores antigos/novos | Sim |
| `Ajudante` | Sim | Sim — mesmo contrato | Sim |
| `Servico` | Sim | Sim — mesmo contrato | Sim |
| `TipoMaquinario` | Sim | Sim — mesmo contrato | Nao (catalogo global) |
| `Material` | Sim | Sim — mesmo contrato | Sim |
| `SetorOperacional` | Sim (com restricao de demandas activas — ver [05-backlog-mvp-glossario.md](05-backlog-mvp-glossario.md#governanca-da-taxonomia-espacial-req-risk-001)) | Sim — mesmo contrato | Sim |
| `Quadra`, `Lote`, `Rua` | Sim (com restricao de demandas activas) | Sim — mesmo contrato | Sim |
| `RegistroExpediente` | Nao (imutavel apos encerramento) | Sim — criacao e encerramento | Sim |

Regras transversais:
- Toda mutacao relevante e registada em tabela de auditoria dedicada (`ResourceAuditLog`) ou, quando ja existente, em `DemandaLog`. O registo preserva `userId`, `entityType`, `entityId`, `obraId`, `action`, `oldValues`, `newValues` e `timestamp`.
- Entidades com `deletadoEm` preenchido permanecem consultaveis para efeitos de historico e auditoria, mas sao excluidas das listas operacionais activas.
- A politica garante que qualquer recurso operacional envolvido numa demanda pode ser rastreado desde a criacao ate ao estado actual, assegurando a rastreabilidade consistente exigida por `REQ-NFR-004`.

## Rastreabilidade de ajudantes

O escopo do MVP associa ajudantes ao expediente e nao diretamente a `Demanda`.

- A presenca do ajudante e registada em `TurnoAjudante`, com inicio e fim do recorte temporal.
- A ligacao entre ajudante e demanda e inferida por intersecao entre os intervalos `[iniciadoEm, finalizadoEm]` e `[inicioVinculo, fimVinculo]`.
- O painel administrativo pode expor um rastreio consultivo por turno, horas totais e lista de maquinas operadas em conjunto.
- Se a troca de ajudante ocorrer com a demanda em `EM_ANDAMENTO`, o sistema deve escrever o evento `TROCA_AJUDANTE` em `DemandaLog`.
- Esse registo tambem segue `offline-queue` com re-tentativa automatica, para nao perder auditabilidade em falhas de rede.
