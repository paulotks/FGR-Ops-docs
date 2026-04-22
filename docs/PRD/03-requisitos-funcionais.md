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
- **Proprietário** (`proprietarioTipo`: `FGR` ou `EMPREITEIRA`, obrigatório) + `empreiteiraId` (UUID, obrigatório quando `proprietarioTipo = EMPREITEIRA`, nulo quando `FGR`). (DEC-016)
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

### `REQ-FUNC-006` Demandas Agendadas: Modelo de Aceite Explícito

O sistema deve suportar criação de demandas com data/hora futura e um fluxo de aceite explícito pelo operador, substituindo a shadow-queue automática anterior. (DEC-026, DEC-027, DEC-028, DEC-029)

**5.1 Criação:**

| Perfil criador | Resultado imediato |
|---|---|
| AdminOp / SuperAdmin | Estado `AGENDADA` (imediato) |
| AdminOp / SuperAdmin + `operadorAlocadoId` | Estado `AGENDADA` com bypass do fluxo de aceite (DEC-001) |
| UsuarioInternoFGR | Estado `AGUARDANDO_APROVACAO` — requer aprovação de AdminOp/SuperAdmin → `AGENDADA` |

**5.2 Visibilidade e Aceite:**

- Demanda `AGENDADA` fica visível na aba "Demandas Agendadas" para todos os operadores com `TipoMaquinario` compatível (broadcast por TipoMaquinario — sem filtro de setor)
- No **check-in** (ou login), pop-up exibe demandas agendadas pendentes de aceite
- Operador pode: **Aceitar** / **Recusar** / **Fechar** (adiar decisão, sem registro de recusa)
- Ao aceitar: `AGENDADA → PENDENTE`, entra na fila do operador
- Restrição: operador não pode aceitar mais de uma demanda no mesmo slot horário (janela configurável por obra)
- Recusa não remove: demanda permanece na aba; log registra `RECUSADA` / `ACEITA_POR_OUTRO` por operador

**5.3 Expiração:**

- Se nenhum operador aceitar até **T-1h** antes da `dataAgendada`: `AGENDADA → NAO_EXECUTADA` (estado terminal)
- Log registra status por operador: `RECUSADA` ou `NAO_RESPONDIDA`

**5.4 Bloqueio T-30:**

- 30 min antes da `dataAgendada`: operador que aceitou não pode iniciar novas demandas da fila
- Demandas em andamento podem ser concluídas; novas não podem ser iniciadas
- Bloqueio permanece até a demanda agendada ser concluída ou cancelada

**5.5 Cancelamento:**

- **AdminOp/SuperAdmin:** cancelam diretamente com observação/motivo obrigatório (qualquer estado)
- **Operador:** solicita cancelamento via botão "Solicitar Cancelamento" → AdminOp recebe no painel e decide (DEC-029)
- Aplica-se mesmo com demanda em `EM_ANDAMENTO` se originada de agendamento

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md) (estados AGUARDANDO_APROVACAO, NAO_EXECUTADA, diagrama final, bloqueio T-30)
-> SPEC: [../SPEC/07-design-ui-logica.md](../SPEC/07-design-ui-logica.md) (pop-up check-in, aba Demandas Agendadas, tela admin)
-> SPEC: [../SPEC/06-definicoes-complementares.md](../SPEC/06-definicoes-complementares.md) (evento WebSocket, janela de aceite)
-> SPEC: [../SPEC/08-api-contratos.md](../SPEC/08-api-contratos.md) (endpoints aceitar, recusar, solicitar-cancelamento)
-> SPEC: [../SPEC/02-modelo-dados.md](../SPEC/02-modelo-dados.md) (campos aceiteOperadorId, aceiteEm, SolicitacaoCancelamentoAgendada)
-> RBAC: [01-usuarios-rbac.md](01-usuarios-rbac.md) (REQ-RBAC-004, REQ-RBAC-006)

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

Quando uma nova demanda é atribuída a um operador cuja fila está vazia, o sistema dispara notificação multi-sensorial (pop-up + alerta sonoro + vibração) para garantir percepção mesmo sem tela ativa. O operador pode iniciar imediatamente ou diferir sem recusar; o cancelamento, quando necessário, segue `REQ-FUNC-009`. Novas demandas com fila ativa entram silenciosamente, reordenadas pelo motor de score. O `AdminOperacional` monitora operadores inativos via dashboard — escalação é manual.

-> SPEC: [../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa](../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa) (UX completa)
-> SPEC: [../SPEC/06-definicoes-complementares.md#regras-de-deduplicacao-e-estado-visual](../SPEC/06-definicoes-complementares.md#regras-de-deduplicacao-e-estado-visual) (mecânica técnica: vibração, som, reconexão offline)

### `REQ-FUNC-014` Rollover e redistribuição de demandas entre dias

O sistema deve realizar rollover de demandas não concluídas ao fim do expediente, redistribuindo-as no dia seguinte conforme operadores fazem check-in.

**Comportamentos obrigatórios:**

1. **Devolução forçada (EM_ANDAMENTO/PAUSADA):** Ao fim do expediente (gatilho duplo: checkout do operador ou worker `expedienteFim`), demandas em `EM_ANDAMENTO` ou `PAUSADA` são devolvidas automaticamente via `devolver_fim_expediente → RETORNADA → PENDENTE` (ator: SISTEMA, justificativa automática: "Devolução automática por fim de expediente").

2. **Rollover de PENDENTE:** Demandas em `PENDENTE` ao fim do expediente permanecem nesse estado com:
   - Campo `rolloverDe` preenchido com a data do dia
   - Campo `operadorId` limpo (sem operador atribuído)
   - SLA agendado para reset no `expedienteInicio` do dia seguinte

3. **Redistribuição no check-in:** No dia seguinte, ao fazer check-in, operadores recebem demandas redistribuídas via pipeline padrão (hard filter completo + scoring normal). Demandas com `rolloverDe` são tratadas como demandas normais — sem estado especial, sem prioridade diferenciada.

4. **SLA sem auto-encerramento:** SLA de demandas roladas mantém alertas e escalação, mas **não** causa auto-encerramento. SLA reseta no `expedienteInicio` do dia seguinte (marco zero = início do expediente).

5. **Indicador visual admin:** Painel admin exibe demandas redistribuídas com badge "Dia anterior".

**Supersede parcialmente:** DEC-002 (parte de auto-encerramento por SLA estourado — removida).
**DEC:** DEC-025

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md) (máquina de estados, worker expedienteFim, rollover)
-> SPEC: [../SPEC/06-definicoes-complementares.md](../SPEC/06-definicoes-complementares.md) (campo rolloverDe, reset de SLA, mecânica do worker)
-> SPEC: [../SPEC/02-modelo-dados.md](../SPEC/02-modelo-dados.md) (campo rolloverDe na entidade Demanda)
-> ACE: [05-criterios-aceite.md#rollover-e-redistribuicao-de-demandas-entre-dias](05-criterios-aceite.md#rollover-e-redistribuicao-de-demandas-entre-dias) (REQ-ACE-010)

## Critérios de aceite relacionados

- [REQ-ACE-002](05-criterios-aceite.md#maquina-de-estados-bloqueio-de-bypass-pos-conclusao)
- [REQ-ACE-003](05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
- [REQ-ACE-010](05-criterios-aceite.md#rollover-e-redistribuicao-de-demandas-entre-dias)
