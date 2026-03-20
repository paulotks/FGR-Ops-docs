# Requisitos funcionais

Esta secção consolida os requisitos funcionais do MVP operacional, com foco na integridade do ciclo de vida das demandas, no despacho de maquinario e na experiencia de execucao em campo.

## Requisitos do modulo operacional

### `REQ-FUNC-001` Maquina de estados de demanda

Uma demanda so pode avancar, retroceder, cancelar ou concluir seguindo rigorosamente os estados e transicoes autorizados. Demandas em `CONCLUIDA` sao definitivas e nao podem regressar a `PENDENTE`, preservando a integridade do cronometro operacional e da trilha de auditoria.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### `REQ-FUNC-002` Filtro estrito por jurisdicao e compatibilidade

No fluxo automatico de distribuicao, maquinas e operadores nao podem visualizar nem receber tarefas fora da jurisdicao logistica atribuida. A elegibilidade depende tambem da compatibilidade entre maquinario e servico. A alocacao manual por `operadorAlocadoId` (ver `REQ-FUNC-006`) constitui excecao explicita e auditavel a estas regras de elegibilidade (DEC-001).

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-003` Gestao de maquinario e ajudantes

O sistema deve suportar o cadastro estruturado de `Tipos de Maquinario`, `Servicos`, `Maquinas` e `Ajudantes`. O `Operador` precisa de estar vinculado aos tipos de maquinario que esta autorizado a operar.

-> SPEC: [../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core](../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core)

### `REQ-FUNC-004` Diario operacional de expediente

O `RegistroExpediente` formaliza diariamente o uso do equipamento, associando `Operador`, `Maquina` e `Ajudante` num periodo temporal. No check-in, o operador escolhe a maquina filtrada pelas suas autorizacoes e regista o ajudante ativo; a troca de ajudante durante o turno deve permanecer auditada. A primeira demanda do dia parte de uma localizacao neutra (`Fora da Obra`) e so depois da primeira conclusao o checkpoint manual passa a influenciar a adjacencia.

-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-005` Agrupamento e criacao multipla

O frontend deve permitir agrupar sequencias de servicos com logica estrutural partilhada e enviar um payload bulk de demandas independentes a partir da mesma experiencia de formulario.

-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)

### `REQ-FUNC-006` Alocacao manual e agendamentos

`AdminOperacional` e `UsuarioInternoFGR` podem criar demandas com atribuicao explicita de operador via `operadorAlocadoId` ou definir uma `dataAgendada` futura. Demandas agendadas permanecem em `AGENDADA` e entram automaticamente na fila pendente 60 minutos antes do horario alvo. A alocacao via `operadorAlocadoId` sobrepoe as regras automaticas de distribuicao e elegibilidade (jurisdicao, proximidade e balanceamento) como excecao de gestao auditavel, mas nao remove o motor de priorizacao da fila do operador. A ordem resultante na fila constitui organizacao recomendada de atendimento, nao bloqueio rigido de execucao (DEC-001).

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### `REQ-FUNC-007` Timers de atendimento

O sistema deve persistir e manipular os atributos temporais da demanda diretamente no dominio, incluindo `iniciadoEm`, `finalizadoEm` e o respetivo calculo de `tempoExecucaoMs`.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca](../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca)

### `REQ-FUNC-008` Prioridade maxima com destaque visual

Demandas de prioridade maxima nao devem bloquear a interface nem ocultar as restantes. O operador deve ver o topo da fila com styling chamativo e contexto suficiente para agir imediatamente.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-009` Workflow de cancelamentos iniciados pelo operador

O operador nao cancela diretamente uma demanda em `EM_ANDAMENTO`. Em vez disso, cria uma `SolicitacaoCancelamento` justificada, movendo a demanda para `PENDENTE_APROVACAO`, onde aguarda decisao administrativa ou aprovacao automatica apos o SLA definido.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao](../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao)

### `REQ-FUNC-010` Adjacencias e localizacao operacional

O produto deve manter cadastro hierarquico espacial de `Quadras`, `Lotes` e `Ruas`, com regras de contiguidade que alimentam o motor de score e a jurisdicao logistica da fila.

-> SPEC: [../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core](../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

## Critérios de aceite relacionados

- [REQ-ACE-002](05-criterios-aceite.md#maquina-de-estados-bloqueio-de-bypass-pos-conclusao)
- [REQ-ACE-003](05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](05-criterios-aceite.md#aprovacao-administrativa-para-cancelamentos-de-operadores)
