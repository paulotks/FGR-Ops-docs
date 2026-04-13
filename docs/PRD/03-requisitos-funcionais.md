# Requisitos funcionais

Esta seção consolida os requisitos funcionais do MVP operacional, com foco na integridade do ciclo de vida das demandas, no despacho de maquinário e na experiência de execução em campo.

## Requisitos do módulo operacional

### `REQ-FUNC-001` Máquina de estados de demanda

Uma demanda só pode avançar, retroceder, cancelar ou concluir seguindo rigorosamente os estados e transições autorizados. Demandas em `CONCLUIDA` são definitivas e não podem regressar a `PENDENTE`, preservando a integridade do cronômetro operacional e da trilha de auditoria.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### `REQ-FUNC-002` Filtro estrito por jurisdição e compatibilidade

No fluxo automático de distribuição, máquinas e operadores não podem visualizar nem receber tarefas fora da jurisdição logística atribuída. A elegibilidade depende também da compatibilidade entre maquinário e serviço. A alocação manual por `operadorAlocadoId` (ver `REQ-FUNC-006`) constitui exceção explícita e auditável a estas regras de elegibilidade (DEC-001).

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-003` Gestão de maquinário, serviços e ajudantes

O sistema deve suportar o cadastro estruturado de `Tipos de Maquinario`, `Servicos`, `Maquinas` e `Ajudantes` via telas dedicadas de administração. O `Operador` precisa de estar vinculado aos tipos de maquinário que está autorizado a operar.

O cadastro de `TipoMaquinario` deve exigir os seguintes campos:

- **Nome** do tipo (obrigatório).
- **Descrição** do tipo (obrigatório).
- Os serviços associados são gerenciados separadamente via cadastro de `Servico`, vinculado ao tipo pelo campo `tipoMaquinarioId`.

O cadastro de `Maquinario` deve exigir os seguintes campos para o MVP:

- **Nome** da máquina (obrigatório).
- **Empresa proprietária** (`empresaProprietaria`, texto livre — obrigatório).
- **Placa** (opcional, para máquinas com registro veicular).
- Vínculo obrigatório ao **TipoMaquinario** correspondente.

A relação `TipoMaquinario → Servico` permite filtragem mútua na criação de demanda: ao selecionar um maquinário, apenas os serviços do seu tipo são exibidos; ao selecionar um serviço, apenas os maquinários do tipo compatível são exibidos.

O cadastro de `Servico` deve exigir no mínimo os seguintes campos:

- **Nome** do serviço (obrigatório).
- **Descrição** do serviço (obrigatório).
- **Exige Transporte** (`exigeTransporte`, flag booleana, padrão `false`): indica que o serviço envolve deslocamento de material ou equipamento dentro da obra. Quando marcada, a abertura de uma demanda para este serviço exige que o empreiteiro informe o destino (Quadra/Lote) ou declare Transporte Interno.

Cada `Servico` é vinculado a um `TipoMaquinario`. Um mesmo tipo pode ter múltiplos serviços associados.

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

`AdminOperacional` e `SuperAdmin` podem criar demandas com atribuição explícita de operador via `operadorAlocadoId` ou definir uma `dataAgendada` futura. O `UsuarioInternoFGR` pode criar demandas simples (`PENDENTE`) sem pré-seleção de operador (DEC-020). Demandas agendadas permanecem em `AGENDADA` e entram automaticamente na fila pendente 60 minutos antes do horário alvo. A alocação via `operadorAlocadoId` sobrepõe as regras automáticas de distribuição e elegibilidade (jurisdição, proximidade e balanceamento) como exceção de gestão auditável, mas não remove o motor de priorização da fila do operador. A ordem resultante na fila constitui organização recomendada de atendimento, não bloqueio rígido de execução (DEC-001).

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

### `REQ-FUNC-009` Cancelamento de demanda em execução pelo operador

O operador pode cancelar diretamente uma demanda em `EM_ANDAMENTO`, registrando obrigatoriamente a justificativa. A demanda transita diretamente para `CANCELADA`, com registro em `DemandaLog` contendo ator, timestamp e motivo. Após o cancelamento, o operador fica disponível para receber a próxima tarefa do topo da fila. (DEC-019)

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

### `REQ-FUNC-010` Adjacências e localização operacional

O produto deve manter cadastro hierárquico espacial de `Quadras`, `Lotes` e `Ruas`, com regras de contiguidade que alimentam o motor de score e a jurisdição logística da fila.

-> SPEC: [../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core](../SPEC/01-modulos-plataforma.md#dependencias-sobre-o-core)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-FUNC-011` Pausa de demanda em andamento (MVP)

O operador pode pausar uma demanda em `EM_ANDAMENTO`, registrando obrigatoriamente o motivo da pausa. A demanda transita para `PAUSADA` e permanece vinculada ao operador. A fila recalcula as próximas tarefas disponíveis para o equipamento enquanto a demanda estiver pausada. O operador pode retomar a demanda pausada, retornando-a a `EM_ANDAMENTO`. As transições `EM_ANDAMENTO → PAUSADA → EM_ANDAMENTO` devem ser registradas em `DemandaLog` com ator, timestamp e motivo.

> **DEC-011 (decidido — 2026-04-09):** Transições `EM_ANDAMENTO → PAUSADA` (ação `pausar`, Operador, justificativa obrigatória) e `PAUSADA → EM_ANDAMENTO` (ação `retomar`, Operador) formalizadas em `SPEC/03`. SLA continua correndo durante pausa. Ver [`docs/audit/decisions-log.md#dec-011`](../audit/decisions-log.md#dec-011---estado-pausada-na-máquina-de-estados-da-demanda-mvp).

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pausada-dec-011](../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pausada-dec-011)

-> SPEC: [../SPEC/07-design-ui-logica.md#mapeamento-visual-de-estados-state-to-ui-mapping](../SPEC/07-design-ui-logica.md#mapeamento-visual-de-estados-state-to-ui-mapping)

### `REQ-FUNC-012` Gestão de Empreiteiras e vínculo com usuário Empreiteiro

O sistema deve suportar o cadastro, consulta, atualização e remoção (soft-delete) de `Empreiteiras` como entidade global — reutilizável entre obras e módulos futuros. O `AdminOperacional` e o `SuperAdmin` são os perfis autorizados a criar e editar. O perfil `Board` e o `UsuarioInternoFGR` possuem acesso de leitura. O `Empreiteiro` pode ler os dados da sua própria empreiteira.

O cadastro de `Empreiteira` deve incluir:

- **Nome** (obrigatório).
- **CNPJ** (opcional no MVP; quando informado, deve ser único globalmente — preparado para tornar-se obrigatório em versão futura).
- **Telefone**, **E-mail**, **Responsável**, **Endereço** (todos opcionais no MVP).

Ao criar um usuário com perfil `Empreiteiro`, o `AdminOperacional` deve obrigatoriamente informar o `empreiteiraId` correspondente. Um usuário `Empreiteiro` sem vínculo com uma `Empreiteira` não pode ser criado. Uma `Empreiteira` pode ter múltiplos usuários `Empreiteiro` vinculados.

O `Maquinario` deve registrar o tipo de propriedade (`proprietarioTipo: FGR | EMPREITEIRA`) e, quando `EMPREITEIRA`, referenciar a `Empreiteira` proprietária via `empreiteiraId`.

> **DEC-016 (decidido — 2026-04-10):** `Empreiteira` promovida a entidade global (sem `obraId`); `User.empreiteiraId` como FK de vínculo; discriminador `proprietarioTipo` em `Maquinario`; sem FK permanente `operadorPadraoId` em `Maquinario`. Ver [`docs/audit/decisions-log.md#dec-016`](../audit/decisions-log.md#dec-016--empreiteira-global-vínculo-empreiteiro--empreiteira-e-modelo-de-propriedade-de-maquinario).

-> SPEC: [../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade](../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade)
-> SPEC: [../SPEC/08-api-contratos.md#6-empreiteiras-empreiteiras](../SPEC/08-api-contratos.md#6-empreiteiras-empreiteiras)

### `REQ-FUNC-013` Notificação de nova demanda para operador com fila vazia

Quando uma nova demanda é atribuída a um operador cuja fila está vazia — seja no início do expediente ou após a conclusão de todas as demandas anteriores — o sistema deve exibir um **pop-up de notificação** acompanhado de alerta sonoro e vibração do dispositivo, garantindo que o operador perceba a chegada da tarefa mesmo sem estar com a tela ativa.

O pop-up deve conter:

- Identificação da demanda: serviço solicitado e localização.
- Botão **"Iniciar Agora"** — demanda transita para `EM_ANDAMENTO` imediatamente.
- Botão **"Iniciar Depois (Perfilar)"** — demanda permanece em `PENDENTE`, o operador retorna à tela de fila; nenhuma transição de estado ocorre.
- **Sem opção de recusa** — a rejeição da demanda não é permitida neste fluxo. O cancelamento, quando necessário, segue o fluxo padrão de cancelamento pelo operador (`REQ-FUNC-009`).

Quando a fila já possui demandas, novas demandas entram diretamente na fila sem pop-up, reordenadas pelo motor de score. A próxima demanda da fila permanece em destaque expandido com ação de início disponível.

O `AdminOperacional` monitora via dashboard os operadores que receberam demandas mas não as iniciaram, sem automação de escalação — o contato é feito manualmente (ex.: rádio).

-> SPEC: [../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa](../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa)

## Critérios de aceite relacionados

- [REQ-ACE-002](05-criterios-aceite.md#maquina-de-estados-bloqueio-de-bypass-pos-conclusao)
- [REQ-ACE-003](05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
