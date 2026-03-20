# Definicoes complementares

**Rastreio PRD:** `REQ-NFR-002`, `REQ-FUNC-004`, `REQ-FUNC-006`, `REQ-FUNC-009`, `REQ-RISK-002`, `REQ-MET-003`

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

## Rastreabilidade de ajudantes

O escopo do MVP associa ajudantes ao expediente e nao diretamente a `Demanda`.

- A presenca do ajudante e registada em `TurnoAjudante`, com inicio e fim do recorte temporal.
- A ligacao entre ajudante e demanda e inferida por intersecao entre os intervalos `[iniciadoEm, finalizadoEm]` e `[inicioVinculo, fimVinculo]`.
- O painel administrativo pode expor um rastreio consultivo por turno, horas totais e lista de maquinas operadas em conjunto.
- Se a troca de ajudante ocorrer com a demanda em `EM_ANDAMENTO`, o sistema deve escrever o evento `TROCA_AJUDANTE` em `DemandaLog`.
- Esse registo tambem segue `offline-queue` com re-tentativa automatica, para nao perder auditabilidade em falhas de rede.
