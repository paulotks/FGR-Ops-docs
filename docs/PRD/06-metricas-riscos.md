# Métricas e riscos

Esta seção consolida os indicadores de sucesso do MVP e os principais riscos operacionais a acompanhar na implantação do FGR-OPS.

## Métricas de sucesso

### `REQ-MET-001` Tempo ocioso em campo

Percentual de horas em que a máquina está disponível mas sem demanda vinculada em `EM_ANDAMENTO`, calculado por `(Horas Disponíveis - Horas em Operação) / Horas Disponíveis`.

- Baseline: recolha manual durante 2 semanas pré-go-live, com planilha de acompanhamento de frota preenchida pelos encarregados de obra.
- Meta MVP: redução de 15% no tempo ocioso nos primeiros 60 dias de uso.

-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)

### `REQ-MET-002` Adoção e engajamento operacional

Razão entre o número de operadores que realizaram pelo menos 1 check-in ou ação no app e o número total de operadores cadastrados e ativos no sistema para a obra na quinzena (DEC-018).

- Baseline: `0%`, dado que o processo atual é analógico ou via rádio.
- Meta MVP: `100%` dos operadores das obras-piloto a registrar todas as movimentações via sistema em até 2 meses.

-> SPEC: [../SPEC/06-definicoes-complementares.md#contrato-analitico-req-met-002](../SPEC/06-definicoes-complementares.md#contrato-analitico-req-met-002)

### `REQ-MET-003` Tempo de espera crítico para prioridade `MAXIMA`

Tempo decorrido entre a entrada da demanda em `PENDENTE` (ou o marco zero do agendamento) e a transição para `EM_ANDAMENTO` em demandas de prioridade `MAXIMA`.

- Baseline: recolha durante 3 semanas pré-go-live por amostragem em diário de obra, com mínimo de 20 ocorrências críticas.
- Meta MVP: `90%` das demandas `MAXIMA` atendidas dentro de SLA de 15 minutos.
- Governança: atrasos superiores a 5 minutos após o SLA (`T+20`) geram escalação automática para `SuperAdmin`.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca](../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca)
-> SPEC: [../SPEC/06-definicoes-complementares.md#comportamento-de-dataagendada](../SPEC/06-definicoes-complementares.md#comportamento-de-dataagendada)

## Riscos e mitigações

### `REQ-RISK-001` Governanca da taxonomia operacional

A evolução da fila depende da manutenção coerente da taxonomia de `Lote`, `Quadra` e `SetorOperacional`. Sem governança administrativa consistente, a obra pode criar gargalos cadastrais e adjacências incorretas, degradando a atribuição automática.

**Mitigação esperada:**
- **Responsável:** `AdminOperacional` da obra, com supervisão de `SuperAdmin`.
- **Validação na criação/edição:** integridade referencial obrigatória (entidades espaciais coerentes dentro da mesma obra).
- **Auditoria cadastral:** toda criação, edição ou exclusão lógica de entidades espaciais gera registro auditável com ator, timestamp e valores antigos/novos.
- **Restrição de exclusão:** entidades espaciais referenciadas por demandas ativas não podem ser removidas.
- **Relatório de consistência:** painel consultivo que identifica lotes sem adjacência, quadras vazias e setores sem operador vinculado.

-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)
-> SPEC: [../SPEC/05-backlog-mvp-glossario.md#governanca-da-taxonomia-espacial-req-risk-001](../SPEC/05-backlog-mvp-glossario.md#governanca-da-taxonomia-espacial-req-risk-001)

### `REQ-RISK-002` Conectividade restrita em campo

Quedas de latência ou indisponibilidade celular exigem uma experiência `offline-first` no PWA, com `Service Workers`, persistência local e sincronização posterior. A resolução de conflitos deve seguir prioridade temporal sobre `iniciadoEm` e `finalizadoEm`, restringindo a interface apenas em operações transacionais críticas como check-in e check-out do turno.

-> SPEC: [../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline](../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline)
