# Módulos da plataforma

**Rastreio PRD:** `REQ-JOR-001`, `REQ-JOR-004`, `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-005`, `REQ-FUNC-010`, `REQ-FUNC-014`, `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-003`, `REQ-SCO-001`, `REQ-SCO-002`, `REQ-SCO-003`, `REQ-SCO-004`

Este módulo consolida as fronteiras de responsabilidade entre o `Core` da plataforma e o `Machinery Link`, explicando onde vivem os dados compartilhados, os fluxos operacionais e as dependências entre contextos.

## Fronteiras de domínio

- O `Core` concentra identidade, organização da obra e estruturas espaciais reutilizáveis por módulos presentes e futuros.
- O `Machinery Link` concentra o ciclo operacional de solicitação, despacho, execução e expediente de maquinários pesados.
- Regras de fila, score, estados e SLA pertencem ao módulo operacional e estão detalhadas em [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md).

## Módulo Core

### Responsabilidade

Fundação da plataforma contendo dados compartilhados entre todos os submódulos futuros.

### Atores envolvidos

- `SuperAdmin`
- `Board`
- `AdminOperacional`

### Capacidades principais

- Gestão de `Obras`.
- Cadastro de `Usuarios`.
- Atribuição de `Perfis` (`Roles`) em relação com setores e escopos de obra.
- Manutenção da malha espacial operacional (`SetorOperacional`, `Quadra`, `Lote`, `Rua`, adjacências).
- Disponibilização de catálogos e metadados usados pelo motor operacional.

## Módulo Machinery Link (MVP)

### Responsabilidade

Gerir o ciclo de vida completo e estrito de solicitações, filas, agrupamentos e expedientes de maquinários pesados.

### Atores envolvidos

- `Empreiteiro` como solicitante.
- `Operador` como executor via mobile.
- `UsuarioInternoFGR` e `AdminOperacional` como gestores da obra.
- `SuperAdmin` para suporte e governança transversal.

### Capacidades operacionais do Machinery Link

1. **Solicitação**: abertura de demandas simples, agrupadas, em lote múltiplo e programações agendadas. Na abertura, o `Empreiteiro` informa obrigatoriamente a localização onde necessita do serviço, selecionando **Quadra/Lote** ou **Local Externo** (Portaria, Pulmão, Garagem, entre outros cadastrados por obra). O `SetorOperacional` é derivado automaticamente da localização, ancorando o pedido ao contexto logístico que alimenta o hard filter de jurisdição e o fator de adjacência do motor de score. O empreiteiro seleciona serviço e maquinário com filtragem mútua pelo catálogo. Opcionalmente, pode selecionar **Material** (para `fator_material` do score) e informar **Destino** (Quadra/Lote) para contextualizar serviços de movimentação. O empreiteiro pode acrescentar descrição complementar antes de submeter (`REQ-JOR-001`).
2. **Agrupamento e criação múltipla**: o frontend permite agrupar sequências de serviços com lógica estrutural compartilhada (mesmo local, mesmo tipo de maquinário) e submeter um payload bulk que gera demandas independentes a partir da mesma experiência de formulário. Cada demanda gerada pelo bulk recebe ID próprio, participa individualmente do pipeline de fila e pode ser concluída ou cancelada de forma autônoma. A relação lógica entre demandas do mesmo lote é preservada em `DemandaGrupo` para rastreabilidade, sem implicar orquestração de execução (`REQ-FUNC-005`).
3. **Gestão da fila**: distribuição transparente filtrada por setores, jurisdição logística e score. Ao fim do expediente, o worker `expedienteFim` executa o rollover de demandas não concluídas: demandas `EM_ANDAMENTO` ou `PAUSADA` são devolvidas forçadamente via `devolver_fim_expediente → RETORNADA → PENDENTE` (ator: SISTEMA); demandas `PENDENTE` permanecem com o campo `rolloverDe` preenchido e SLA agendado para reset no `expedienteInicio` do dia seguinte. No dia seguinte, demandas redistribuídas entram no pipeline padrão (hard filter + scoring) durante o check-in dos operadores. (`REQ-FUNC-014`, DEC-025)
4. **Execução**: fluxo de campo para assumir, concluir, devolver ou contestar tarefas via máquina de estados.
5. **Expediente**: controle de início e fim da jornada operacional do maquinário, com máquina e ajudante ativos.
6. **Operações dinâmicas**: alocação manual, empilhamento não destrutivo e trilha de auditoria obrigatória.

## Dependências sobre o Core

- O `Machinery Link` depende do `Core` para conhecer `Obra`, `User`, `Role` e o recorte tenant-scoped.
- O filtro logístico usa entidades espaciais mantidas no `Core`, como `SetorOperacional`, `Quadra`, `Lote`, `Rua` e relações de adjacência.
- O catálogo de `Tipos de Maquinario`, `Maquinarios`, `Servicos` e autorizações do `Operador` determina elegibilidade de atendimento.
- O `RegistroExpediente` combina referências do `Core` com o estado operacional corrente para definir contexto de execução.

## Bootstrapping de obra {#bootstrapping-de-obra}

A ativação de uma obra ocorre em **duas camadas**: primeiro no **FGR Ops** (plataforma multi-módulo), depois no **Machinery Link** (módulo operacional). O Machinery Link é o primeiro módulo entregue no MVP; futuros módulos (almoxarifado, rastreamento IoT, painel executivo — ver `REQ-SCO-F2-*` em [05-backlog-mvp-glossario.md](05-backlog-mvp-glossario.md)) seguirão o mesmo padrão de ativação por obra, sem impacto retroativo nesta sequência.

### Arquitetura de duas camadas

| Camada | Escopo | Responsabilidade | Perfis |
| :--- | :--- | :--- | :--- |
| **FGR Ops** (plataforma) | `cross-tenant` | Cadastro de `Obra`, provisão de usuários de plataforma, ativação de módulos por obra, visão agregada de leitura. | `SuperAdmin`, `Board` |
| **Machinery Link** (módulo) | `tenant-scoped` (por `obraId`) | Cadastros operacionais internos, catálogos, maquinário, operadores, empreiteiras, parâmetros de fila e ciclo de vida de `Demanda`. | `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro`, `Operador` |

**Mapeamento de nomenclatura funcional ↔ perfil técnico:**

- O perfil `SuperAdmin` cumpre o papel operacional de **Administrador do Sistema FGR Ops**: é o único com `core:obra:create` (ver [04-rbac-permissoes.md](04-rbac-permissoes.md#matriz-completa-de-permissoes-por-recurso-lacuna-1)), e é quem provisiona usuários de plataforma e ativa módulos por obra.
- O perfil `Board` cumpre o papel funcional de **Diretor / Gerente de Obra Global**: acesso cross-tenant estritamente de leitura (`HTTP GET`), voltado à consolidação analítica entre obras. O painel executivo dedicado com cruzamento de dados entre obras (ex.: horas de maquinário por obra, engajamento de operadores) fica no backlog da Fase 2 como módulo futuro do FGR Ops.
- Os perfis `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` e `Operador` operam **dentro do módulo Machinery Link**, já escopados por `obraId` pelo middleware de multi-tenancy (D4).

### Fluxo de autenticação e roteamento de entrada

O FGR Ops expõe **dois pontos de entrada** distintos para minimizar fricção operacional em campo. Ambos compartilham o mesmo stack de autenticação (JWT + RBAC conforme D3 e D6); a diferença é exclusivamente a rota de entrada na aplicação web/PWA.

1. **Shell FGR Ops** — usado por `SuperAdmin` e `Board`. Após o login, o usuário seleciona a obra e visualiza o **hub de módulos habilitados** para aquela obra. No MVP, o único módulo exibido é o Machinery Link. A partir do hub, o usuário acessa o contexto do módulo mantendo a sessão.
2. **Acesso direto ao Machinery Link** — usado por `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` e `Operador`. Estes perfis entram diretamente na aplicação do módulo, sem passar pelo hub, porque sua jurisdição é sempre uma obra pré-atribuída no momento da criação do usuário. Para perfis de campo (`Empreiteiro`, `Operador`), esse acesso direto é especialmente crítico para reduzir toques e latência em smartphone (`REQ-NFR-002`, `REQ-OBJ-005`).

O ponto de entrada correto é determinado pelo perfil do token JWT; tentativas de acesso cruzado (`Operador` tentando carregar o shell FGR Ops, por exemplo) são redirecionadas ao seu fluxo canônico sem erro visível.

### Sequência canônica de cadastros

A tabela abaixo lista a ordem mínima de cadastros para uma obra ficar operacionalmente pronta para criação de demandas no Machinery Link. Cada linha explicita a camada responsável, o perfil executor e as dependências.

| # | Cadastro | Camada | Perfil executor | Dependência |
| :-- | :--- | :--- | :--- | :--- |
| 1 | `Obra` | FGR Ops | `SuperAdmin` | — |
| 2 | Ativar módulo `Machinery Link` para a `Obra` | FGR Ops | `SuperAdmin` | 1 |
| 3 | Usuários de módulo (`AdminOperacional`, `UsuarioInternoFGR`) vinculados à obra | FGR Ops | `SuperAdmin` | 1 |
| 4 | `SetorOperacional` | Machinery Link | `AdminOperacional` | 2 |
| 5 | `Rua` (opcional — descritiva, ver DEC-012) | Machinery Link | `AdminOperacional` | 2 |
| 6 | `Quadra` | Machinery Link | `AdminOperacional` | 4 (`setorOperacionalId`), 5 (opcional) |
| 7 | `Lote` | Machinery Link | `AdminOperacional` | 6 |
| 8 | `LoteAdjacencia` (malha de contiguidade para `fator_adjacencia`) | Machinery Link | `AdminOperacional` | 7 |
| 9 | `LocalExterno` (Portaria, Pulmão, Garagem, etc.) | Machinery Link | `AdminOperacional` | 4 |
| 10 | `TipoMaquinario` (catálogo global — reutilizado entre obras) | Machinery Link | `AdminOperacional` | — |
| 11 | `Servico` (vinculado a `TipoMaquinario`; flag `exigeTransporte`) | Machinery Link | `AdminOperacional` | 10 |
| 12 | `Material` (catálogo da obra, para `fator_material` do score) | Machinery Link | `AdminOperacional` | 2 |
| 13 | `Empreiteira` (quando houver maquinário ou empreiteiros terceirizados) | Machinery Link | `AdminOperacional` | 2 |
| 14 | `Maquinario` (vinculado a `TipoMaquinario`, `Obra` e propriedade — FGR ou `Empreiteira`) | Machinery Link | `AdminOperacional` | 2, 10, 13 (se terceirizado) |
| 15 | Usuários `Empreiteiro` vinculados à `Empreiteira` | Machinery Link | `AdminOperacional` | 13 |
| 16 | Usuários `Operador` com habilitação por `TipoMaquinario` | Machinery Link | `AdminOperacional` | 10 |
| 17 | `Ajudante` (recurso humano sem credencial própria) | Machinery Link | `AdminOperacional` | 2 |
| 18 | Parâmetros operacionais: `expedienteInicio`, `expedienteFim`, pesos da fila (`W_adj`, `W_srv`, `W_mat`) | Machinery Link | `AdminOperacional` | 2 |

### Regras de integridade do bootstrapping

- Uma `Obra` só fica **elegível para criação de demandas** quando estão presentes, no mínimo: `SetorOperacional` (#4), `Quadra` (#6), `Lote` (#7), `TipoMaquinario` (#10), `Servico` (#11), pelo menos um `Maquinario` ativo (#14), pelo menos um `Operador` habilitado (#16) e os parâmetros operacionais (#18). A ausência de qualquer um desses itens deve ser bloqueada pelo backend com mensagem explícita indicando o cadastro faltante.
- Os defaults de pesos da fila (`W_adj=50`, `W_srv=30`, `W_mat=20`) aplicam-se quando o passo #18 não informa valores explícitos — conforme [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md). O horário de expediente **não tem default** e deve ser informado explicitamente por obra, pois governa o auto-encerramento de SLA (ver DEC-002).
- Os passos #3, #15 e #16 respeitam a política de autenticação segmentada por perfil (D6 / DEC-004): perfis administrativos usam palavra-passe forte com rotação de 180 dias; perfis de campo (`Empreiteiro`, `Operador`) usam PIN numérico de 6 dígitos com rotação de 90 dias.
- `LoteAdjacencia` (#8) é pré-requisito para que o motor de score produza `fator_adjacencia` diferente do default neutro; sua ausência não bloqueia a criação de demandas mas degrada a qualidade da priorização automática.

### Delimitação de responsabilidades FGR Ops ↔ Machinery Link (MVP)

**No escopo do FGR Ops (plataforma) no MVP:**

- Cadastro de `Obra` (único ponto de criação).
- Provisão de usuários de plataforma (`SuperAdmin`, `Board`) e de usuários de módulo (`AdminOperacional`, `UsuarioInternoFGR`).
- Ativação do módulo `Machinery Link` por obra (toggle binário, sem configuração fina).
- Shell com seleção de obra → hub de módulos habilitados para o perfil.

**No escopo do Machinery Link (módulo) no MVP:**

- Todos os cadastros operacionais internos à obra (setor, rua, quadra, lote, adjacência, local externo, material, catálogos de tipo/serviço/maquinário, empreiteira, ajudante).
- Provisão e habilitação de usuários `Empreiteiro` e `Operador` vinculados à obra.
- Configuração dos parâmetros operacionais da obra (expediente, pesos de fila).
- Ciclo de vida completo da `Demanda` conforme [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md).
- Execução em campo, expediente, checkpoint manual e rastreabilidade auditável.

**Fora do escopo MVP (Fase 2):**

- Módulos adicionais da plataforma (Almoxarifado, Rastreamento IoT — `REQ-SCO-F2-001..003`).
- Painel executivo dedicado do FGR Ops com cruzamento de dados entre obras para o perfil `Board` (além dos relatórios de leitura já previstos em [04-rbac-permissoes.md](04-rbac-permissoes.md)).
- Ativação/desativação dinâmica de módulos por obra além do toggle binário inicial do Machinery Link.
- Marketplace ou catálogo de módulos de terceiros.

> **Decisão aplicada:** DEC-014 (2026-04-09) — Fronteira FGR Ops (plataforma) ↔ Machinery Link (módulo) e sequência canônica de bootstrapping de obra. Ver [`docs/audit/decisions-log.md#dec-014`](../audit/decisions-log.md#dec-014---fronteira-fgr-ops-plataforma-vs-machinery-link-módulo-e-sequência-de-bootstrapping-de-obra).

## Critérios de aceite suportados

- [REQ-ACE-004](../PRD/05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](../PRD/05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](../PRD/05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
