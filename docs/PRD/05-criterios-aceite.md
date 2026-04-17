# Critérios de aceite

Esta seção agrega critérios testáveis do PRD original. Nesta etapa ficam migrados os critérios ligados a RBAC, isolamento multi-tenant e ao fluxo operacional do Machinery Link.

## Isolamento RBAC e multi-tenancy

**REQ-ACE-001** O sistema deve garantir isolamento de dados por obra para perfis tenant-scoped e visibilidade consolidada controlada para perfis `cross-tenant`.

→ SPEC: [../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass](../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass)

**Cenário 1: Isolamento de dados entre Empreiteiros**

```gherkin
Given que o usuário está autenticado com o perfil 'Empreiteiro' vinculado à 'Obra A'
When o usuário solicita a listagem de demandas ativas no sistema
Then o sistema deve retornar apenas as demandas cujo campo 'obraId' seja igual ao ID da 'Obra A'
```

**Cenário 2: Visibilidade Cross-tenant para Board**

```gherkin
Given que o usuário está autenticado com o perfil 'Board'
When o usuário acessa o dashboard global de produtividade
Then o sistema deve exibir dados agregados de todas as obras cadastradas sem restrição de tenant
```

## Máquina de estados: bloqueio de bypass pós-conclusão

**REQ-ACE-002** O sistema deve impedir transições inválidas após a conclusão da demanda, preservando a integridade da máquina de estados e da auditoria operacional.

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

**Cenário: Tentativa de cancelamento por Operador em demanda concluída**

```gherkin
Given que uma demanda possui o status atual 'CONCLUIDA'
When um usuário com perfil 'Operador' tenta executar a ação 'CANCELAR' nesta demanda
Then o sistema deve rejeitar a transição e retornar uma mensagem de erro de permissão de estado
```

## Jurisdição logística sobre preferências no score

**REQ-ACE-003** O ranking da fila do operador deve respeitar a jurisdição logística e os fatores de score definidos para todas as demandas presentes na fila, incluindo as atribuídas via `operadorAlocadoId`. A alocação manual determina a que operador a demanda é dirigida, mas não isenta a demanda da priorização por score. A ordem resultante é uma organização recomendada de atendimento, não um bloqueio rígido de execução (DEC-001).

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

**Cenário 1: Adjacência espacial supera demanda alocada manualmente na ordenação da fila**

```gherkin
Given que um Operador possui na fila uma demanda 'A' atribuída via operadorAlocadoId cuja quadra é diferente da posição atual do operador e uma demanda 'B' com 'Adjacência Espacial' favorável (mesma quadra)
When o motor de scoring calcula a pontuação para a fila deste Operador
Then a demanda 'B' deve receber uma pontuação de ranking superior à demanda 'A'
```

**Cenário 2: Alocação manual a operador fora da zona é aceite como excepção auditável**

```gherkin
Given que um AdminOperacional cria uma demanda com operadorAlocadoId apontando para um Operador fora do SetorOperacional da demanda
When a demanda é criada no sistema
Then a demanda deve ser atribuída ao Operador indicado, entrar na sua fila para priorização normal por score e gerar registo auditável da excepção de jurisdição
```

## Audit log com justificativa em modificações gerenciais

**REQ-ACE-004** Toda modificação gerencial relevante na demanda deve gerar registro auditável com justificativa obrigatória.

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)

**Cenário: Registro de alteração administrativa**

```gherkin
Given que um 'AdminOperacional' altera o 'OperadorAlocado' de uma demanda existente
When o Admin confirma a alteração inserindo o texto de justificativa obrigatório
Then o sistema deve criar um registro na tabela 'AuditLog' contendo o ID do usuário, timestamp, valores (antigo/novo) e a justificativa fornecida
```

## Destaque visual de prioridade máxima na UI mobile

**REQ-ACE-005** Demandas de prioridade máxima devem permanecer visíveis e destacadas no topo da fila mobile sem suprimir as restantes.

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

**Cenário: Exibição de demanda crítica sem supressão**

```gherkin
Given que existem 3 demandas na fila do Operador, sendo uma delas de prioridade 'MAXIMA'
When o Operador acessa a tela de 'Minhas Tarefas' no aplicativo mobile
Then a demanda 'MAXIMA' deve ser exibida com borda pulsante vermelha no topo da lista, mantendo as outras 2 demandas visíveis e roláveis abaixo
```

## Cancelamento de demanda em execução pelo operador

**REQ-ACE-006** O cancelamento de uma demanda em `EM_ANDAMENTO` pelo operador deve transitar diretamente para `CANCELADA`, exigindo justificativa obrigatória. A trilha auditável é obrigatória, registrando ator, timestamp e motivo em `DemandaLog`. (DEC-019)

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

**Cenário 1: Cancelamento direto pelo Operador com justificativa**

```gherkin
Given que um usuário 'Operador' solicita o cancelamento de uma demanda em 'EM_ANDAMENTO'
  And o operador preenche a justificativa obrigatória no formulário
When a confirmação de cancelamento é enviada via aplicativo
Then o status da demanda deve transitar imediatamente para 'CANCELADA'
  And o sistema deve registrar em 'DemandaLog' o ator, timestamp e motivo fornecido
  And o operador deve ser disponibilizado para receber a próxima tarefa da fila
```

**Cenário 2: Bloqueio de cancelamento sem justificativa**

```gherkin
Given que um usuário 'Operador' tenta cancelar uma demanda em 'EM_ANDAMENTO'
When a requisição é enviada sem preenchimento do campo de justificativa
Then o sistema deve rejeitar a operação com erro de validação
  And a demanda deve permanecer em 'EM_ANDAMENTO'
```

## Segurança de token e gestão de sessão

**REQ-ACE-007** O sistema deve garantir que tokens JWT seguem política de sessão curta, rotação de refresh token e capacidade de invalidação imediata, conforme a arquitetura de autenticação definida.

→ SPEC: [../SPEC/00-visao-arquitetura.md#decisoes-arquiteturais-adrs](../SPEC/00-visao-arquitetura.md#decisoes-arquiteturais-adrs)

**Cenário 1: Expiração e renovação de token**

```gherkin
Given que um usuário autenticado possui um access token válido
When o access token expira após 15 minutos
Then o sistema deve rejeitar requisições com HTTP 401
  And permitir renovação silenciosa via refresh token rotativo (TTL de 7 dias)
  And invalidar o refresh token anterior após uso
```

**Cenário 2: Invalidação imediata por logout**

```gherkin
Given que um usuário autenticado realiza logout explícito
When o pedido de logout é processado pelo backend
Then o sistema deve adicionar o jti do access token e do refresh token a blacklist em Redis
  And rejeitar qualquer requisição subsequente com os tokens invalidados
```

**Cenário 3: Detecção de reuso de refresh token**

```gherkin
Given que um refresh token já foi utilizado para obter um novo par de tokens
When um atacante tenta reutilizar o mesmo refresh token
Then o sistema deve rejeitar a requisição, invalidar toda a cadeia de tokens do usuário e registrar o evento em AuthAuditLog
```

## Isolamento Cross-Tenant Auditado

**REQ-ACE-008** O bypass `cross-tenant` deve ser auditado e o perfil `Board` deve permanecer estritamente limitado a leitura.

→ SPEC: [../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass](../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass)

**Cenário: Auditoria de acessos privilegiados e restrição de escrita para Board**

```gherkin
Given que um perfil 'Board' ou 'SuperAdmin' acessa dados de múltiplas obras
When a consulta é executada via bypass de multi-tenancy
Then o sistema deve registrar o evento no 'AuditLogCrossTenant' com detalhes do ator e recurso

Given que um usuário com perfil 'Board' tenta realizar uma operação de escrita (POST, PUT, PATCH, DELETE)
When o Guard de segurança avalia a requisição
Then o sistema deve retornar HTTP 403 independentemente do payload ou tenant
```

## Notificação de nova demanda para operador com fila vazia

**REQ-ACE-009** Quando uma nova demanda é atribuída a um operador com fila vazia, o sistema deve exibir pop-up com alerta sonoro e vibração; as opções "Iniciar Agora" e "Iniciar Depois (Perfilar)" devem produzir os efeitos corretos na máquina de estados e na fila. Quando a fila não está vazia, a nova demanda deve entrar silenciosamente na fila sem pop-up.

→ SPEC: [../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa](../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa)
→ SPEC: [../SPEC/06-definicoes-complementares.md#mecanismo-notificacao-realtime](../SPEC/06-definicoes-complementares.md#mecanismo-notificacao-realtime)

**Cenário 1: Fila vazia — pop-up com alerta**

```gherkin
Given que o Operador possui fila vazia (sem demandas PENDENTE ou EM_ANDAMENTO)
When uma nova demanda é enfileirada para este Operador
Then o sistema deve emitir evento DEMAND_QUEUED com filaVazia = true
  And o aplicativo deve exibir o pop-up de notificação com alerta sonoro e vibração
  And os botões "Iniciar Agora" e "Iniciar Depois (Perfilar)" devem estar visíveis
  And não deve haver botão de recusa
```

**Cenário 2: "Iniciar Agora" — transição imediata para EM_ANDAMENTO**

```gherkin
Given que o pop-up de notificação está visível para o Operador
When o Operador toca "Iniciar Agora"
Then o sistema deve executar PATCH /demandas/:id/estado com acao "iniciar"
  And a demanda deve transitar de PENDENTE para EM_ANDAMENTO
  And o pop-up deve ser fechado e o card ativo da demanda deve ser exibido
```

**Cenário 3: "Iniciar Depois (Perfilar)" — demanda permanece PENDENTE**

```gherkin
Given que o pop-up de notificação está visível para o Operador
When o Operador toca "Iniciar Depois (Perfilar)"
Then nenhuma transição de estado deve ocorrer na demanda
  And o pop-up deve ser fechado
  And o Operador deve retornar à tela de fila com a demanda no topo (card expandido)
```

**Cenário 4: Fila ativa — sem pop-up**

```gherkin
Given que o Operador possui pelo menos uma demanda na fila (PENDENTE ou EM_ANDAMENTO)
When uma nova demanda é enfileirada para este Operador
Then o sistema deve emitir evento DEMAND_QUEUED com filaVazia = false
  And nenhum pop-up deve ser exibido
  And a fila deve ser reordenada silenciosamente pelo motor de score
```

**Cenário 5: Reconexão após offline com fila que estava vazia**

```gherkin
Given que o Operador estava offline quando uma nova demanda foi enfileirada
  And o último estado salvo da fila era vazio (ver SPEC/06 — estratégia de persistência offline)
When o Operador reconecta e a fila é reidratada via GET /operadores/:id/fila
Then o aplicativo deve exibir o pop-up de notificação com alerta sonoro e vibração
  And o comportamento deve ser idêntico ao do Cenário 1
```
