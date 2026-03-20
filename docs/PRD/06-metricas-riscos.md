# Metricas e riscos

Esta secao consolida os indicadores de sucesso do MVP e os principais riscos operacionais a acompanhar na implantacao do FGR-OPS.

## Metricas de sucesso

### `REQ-MET-001` Tempo ocioso em campo

Percentual de horas em que a maquina esta disponivel mas sem demanda vinculada em `EM_ANDAMENTO`, calculado por `(Horas Disponiveis - Horas em Operacao) / Horas Disponiveis`.

- Baseline: recolha manual durante 2 semanas pre-go-live, com planilha de acompanhamento de frota preenchida pelos encarregados de obra.
- Meta MVP: reducao de 15% no tempo ocioso nos primeiros 60 dias de uso.

-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)

### `REQ-MET-002` Adocao e engajamento operacional

Razao entre o numero de operadores que realizaram pelo menos 1 check-in ou acao no app e o numero total de operadores ativos na folha da quinzena.

- Baseline: `0%`, dado que o processo atual e analogico ou via radio.
- Meta MVP: `100%` dos operadores das obras-piloto a registar todas as movimentacoes via sistema em ate 2 meses.

-> SPEC: [../SPEC/06-definicoes-complementares.md#contrato-analitico-req-met-002](../SPEC/06-definicoes-complementares.md#contrato-analitico-req-met-002)

### `REQ-MET-003` Tempo de espera critica para prioridade `MAXIMA`

Tempo decorrido entre a entrada da demanda em `PENDENTE` (ou o marco zero do agendamento) e a transicao para `EM_ANDAMENTO` em demandas de prioridade `MAXIMA`.

- Baseline: recolha durante 3 semanas pre-go-live por amostragem em diario de obra, com minimo de 20 ocorrencias criticas.
- Meta MVP: `90%` das demandas `MAXIMA` atendidas dentro de SLA de 15 minutos.
- Governanca: atrasos superiores a 5 minutos apos o SLA (`T+20`) geram escalacao automatica para `SuperAdmin`.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca](../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca)
-> SPEC: [../SPEC/06-definicoes-complementares.md#comportamento-de-dataagendada](../SPEC/06-definicoes-complementares.md#comportamento-de-dataagendada)

## Riscos e mitigacoes

### `REQ-RISK-001` Governanca da taxonomia operacional

A evolucao da fila depende da manutencao coerente da taxonomia de `Lote`, `Quadra` e `SetorOperacional`. Sem governanca administrativa consistente, a obra pode criar gargalos cadastrais e adjacencias incorretas, degradando a atribuicao automatica.

**Mitigacao esperada:**
- **Responsavel:** `AdminOperacional` da obra, com supervisao de `SuperAdmin`.
- **Validacao na criacao/edicao:** integridade referencial obrigatoria (entidades espaciais coerentes dentro da mesma obra).
- **Auditoria cadastral:** toda criacao, edicao ou exclusao logica de entidades espaciais gera registo auditavel com ator, timestamp e valores antigos/novos.
- **Restricao de exclusao:** entidades espaciais referenciadas por demandas activas nao podem ser removidas.
- **Relatorio de consistencia:** painel consultivo que identifica lotes sem adjacencia, quadras vazias e setores sem operador vinculado.

-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)
-> SPEC: [../SPEC/05-backlog-mvp-glossario.md#governanca-da-taxonomia-espacial-req-risk-001](../SPEC/05-backlog-mvp-glossario.md#governanca-da-taxonomia-espacial-req-risk-001)

### `REQ-RISK-002` Conectividade restrita em campo

Quedas de latencia ou indisponibilidade celular exigem uma experiencia `offline-first` no PWA, com `Service Workers`, persistencia local e sincronizacao posterior. A resolucao de conflitos deve seguir prioridade temporal sobre `iniciadoEm` e `finalizadoEm`, restringindo a interface apenas em operacoes transacionais criticas como check-in e check-out do turno.

-> SPEC: [../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline](../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline)
