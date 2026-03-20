# Critérios de aceite

Esta secção agrega critérios testáveis do PRD original. Nesta etapa ficam migrados os critérios ligados a RBAC, isolamento multi-tenant e ao fluxo operacional do Machinery Link.

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

## Maquina de estados: bloqueio de bypass pos-conclusao

**REQ-ACE-002** O sistema deve impedir transições inválidas após a conclusão da demanda, preservando a integridade da máquina de estados e da auditoria operacional.

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)

**Cenário: Tentativa de cancelamento por Operador em demanda concluída**

```gherkin
Given que uma demanda possui o status atual 'CONCLUIDA'
When um usuário com perfil 'Operador' tenta executar a ação 'CANCELAR' nesta demanda
Then o sistema deve rejeitar a transição e retornar uma mensagem de erro de permissão de estado
```

## Jurisdicao logistica sobre preferencias no score

**REQ-ACE-003** O ranking da fila do operador deve respeitar a jurisdição logística e os fatores de score definidos para todas as demandas presentes na fila, incluindo as atribuídas via `operadorAlocadoId`. A alocação manual determina a que operador a demanda é dirigida, mas não isenta a demanda da priorização por score. A ordem resultante é uma organização recomendada de atendimento, não um bloqueio rígido de execução (DEC-001).

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

**Cenário 1: Adjacência espacial supera demanda alocada manualmente na ordenação da fila**

```gherkin
Given que um Operador possui na fila uma demanda 'A' atribuída via operadorAlocadoId cuja quadra é diferente da posição actual do operador e uma demanda 'B' com 'Adjacência Espacial' favorável (mesma quadra)
When o motor de scoring calcula a pontuação para a fila deste Operador
Then a demanda 'B' deve receber uma pontuação de ranking superior à demanda 'A'
```

**Cenário 2: Alocação manual a operador fora da zona é aceite como excepção auditável**

```gherkin
Given que um AdminOperacional cria uma demanda com operadorAlocadoId apontando para um Operador fora do SetorOperacional da demanda
When a demanda é criada no sistema
Then a demanda deve ser atribuída ao Operador indicado, entrar na sua fila para priorização normal por score e gerar registo auditável da excepção de jurisdição
```

## Audit log com justificativa em modificacoes gerenciais

**REQ-ACE-004** Toda modificação gerencial relevante na demanda deve gerar registo auditável com justificativa obrigatória.

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)

**Cenário: Registro de alteração administrativa**

```gherkin
Given que um 'AdminOperacional' altera o 'OperadorAlocado' de uma demanda existente
When o Admin confirma a alteração inserindo o texto de justificativa obrigatório
Then o sistema deve criar um registro na tabela 'AuditLog' contendo o ID do usuário, timestamp, valores (antigo/novo) e a justificativa fornecida
```

## Destaque visual de prioridade maxima na UI mobile

**REQ-ACE-005** Demandas de prioridade máxima devem permanecer visíveis e destacadas no topo da fila mobile sem suprimir as restantes.

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

**Cenário: Exibição de demanda crítica sem supressão**

```gherkin
Given que existem 3 demandas na fila do Operador, sendo uma delas de prioridade 'MAXIMA'
When o Operador acessa a tela de 'Minhas Tarefas' no aplicativo mobile
Then a demanda 'MAXIMA' deve ser exibida com borda pulsante vermelha no topo da lista, mantendo as outras 2 demandas visíveis e roláveis abaixo
```

## Aprovacao administrativa para cancelamentos de operadores

**REQ-ACE-006** O cancelamento iniciado em campo pelo operador deve transitar por revisão administrativa antes do encerramento definitivo da demanda.

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao](../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao)

**Cenário: Fluxo de cancelamento iniciado em campo**

```gherkin
Given que um usuário 'Operador' solicita o cancelamento de uma demanda em 'EM_ANDAMENTO'
When a solicitação é enviada via aplicativo
Then o status da demanda deve transitar para 'PENDENTE_APROVACAO' e aparecer no dashboard do AdminOperacional para revisão
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

## Pendentes de migração

O critério `REQ-ACE-007` (segurança de token) permanece por migrar em etapa posterior.
