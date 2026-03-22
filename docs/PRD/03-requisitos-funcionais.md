# Requisitos funcionais

Esta seção consolida os requisitos funcionais do MVP operacional, com foco na integridade do ciclo de vida das demandas, no despacho de maquinário e na experiência de execução em campo.

## Requisitos do módulo operacional

### `REQ-FUNC-001` Máquina de estados de demanda

Uma demanda só pode avançar, retroceder, cancelar ou concluir seguindo rigorosamente os estados e transições autorizados. Demandas em `CONCLUIDA` são definitivas e não podem regressar a `PENDENTE`, preservando a integridade do cronômetro operacional e da trilha de auditoria.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### `REQ-FUNC-002` Filtro estrito por jurisdição e compatibilidade

No fluxo automático de distribuição, máquinas e operadores não podem visualizar nem receber tarefas fora da jurisdição logística atribuída. A elegibilidade depende também da compatibilidade entre maquinário e serviço. A alocação manual por `operadorAlocadoId` (ver `REQ-FUNC-006`) constitui exceção explícita e auditável a estas regras de elegibilidade (DEC-001).

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-003` Gestão de maquinário e ajudantes

O sistema deve suportar o cadastro estruturado de `Tipos de Maquinario`, `Servicos`, `Maquinas` e `Ajudantes`. O `Operador` precisa de estar vinculado aos tipos de maquinário que está autorizado a operar.

-> SPEC: [../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core](../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)

### `REQ-FUNC-004` Diário operacional de expediente

O `RegistroExpediente` formaliza diariamente o uso do equipamento, associando `Operador`, `Maquina` e `Ajudante` num período temporal. No check-in, o operador escolhe a máquina filtrada pelas suas autorizações e registra o ajudante ativo; a troca de ajudante durante o turno deve permanecer auditada. A primeira demanda do dia parte de uma localização neutra (`Fora da Obra`) e só depois da primeira conclusão o checkpoint manual passa a influenciar a adjacência.

-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)
-> SPEC: [../SPEC/06-definicoes-complementares.md#rastreabilidade-de-ajudantes](../SPEC/06-definicoes-complementares.md#rastreabilidade-de-ajudantes)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-005` Agrupamento e criação múltipla

O frontend deve permitir agrupar sequências de serviços com lógica estrutural compartilhada e enviar um payload bulk de demandas independentes a partir da mesma experiência de formulário.

-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)

### `REQ-FUNC-006` Alocação manual e agendamentos

`AdminOperacional` e `UsuarioInternoFGR` podem criar demandas com atribuição explícita de operador via `operadorAlocadoId` ou definir uma `dataAgendada` futura. Demandas agendadas permanecem em `AGENDADA` e entram automaticamente na fila pendente 60 minutos antes do horário alvo. A alocação via `operadorAlocadoId` sobrepõe as regras automáticas de distribuição e elegibilidade (jurisdição, proximidade e balanceamento) como exceção de gestão auditável, mas não remove o motor de priorização da fila do operador. A ordem resultante na fila constitui organização recomendada de atendimento, não bloqueio rígido de execução (DEC-001).

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### `REQ-FUNC-007` Timers de atendimento

O sistema deve persistir e manipular os atributos temporais da demanda diretamente no domínio, incluindo `iniciadoEm`, `finalizadoEm` e o respectivo cálculo de `tempoExecucaoMs`.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca](../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca)
-> SPEC: [../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade](../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade)
-> SPEC: [../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline](../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline)

### `REQ-FUNC-008` Prioridade maxima com destaque visual

Demandas de prioridade máxima não devem bloquear a interface nem ocultar as restantes. O operador deve ver o topo da fila com styling chamativo e contexto suficiente para agir imediatamente.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-009` Workflow de cancelamentos iniciados pelo operador

O operador não cancela diretamente uma demanda em `EM_ANDAMENTO`. Em vez disso, cria uma `SolicitacaoCancelamento` justificada, movendo a demanda para `PENDENTE_APROVACAO`, onde aguarda decisão administrativa ou aprovação automática após o SLA definido.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao](../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao)

### `REQ-FUNC-010` Adjacências e localização operacional

O produto deve manter cadastro hierárquico espacial de `Quadras`, `Lotes` e `Ruas`, com regras de contiguidade que alimentam o motor de score e a jurisdição logística da fila.

-> SPEC: [../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core](../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

## Critérios de aceite relacionados

- [REQ-ACE-002](05-criterios-aceite.md#maquina-de-estados-bloqueio-de-bypass-pos-conclusao)
- [REQ-ACE-003](05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
