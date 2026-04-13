---
id: 07-design-ui-logica
title: Logica de Interface e UX (Angular 20)
area: UI/UX e Frontend
---

# Design de UI e Lógica de Interface

**Rastreio PRD:** `REQ-JOR-001`, `REQ-JOR-002`, `REQ-JOR-003`, `REQ-JOR-004`, `REQ-JOR-005`, `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-003`, `REQ-RBAC-004`, `REQ-RBAC-005`, `REQ-RBAC-006`, `REQ-FUNC-001`, `REQ-FUNC-008`, `REQ-FUNC-009`, `REQ-FUNC-011`, `REQ-FUNC-013`, `REQ-NFR-002`, `REQ-ACE-006`

Este documento serve como a **ponte visual e técnica** entre as regras de negócio documentadas (RBAC, Fila, SLAs) e a implementação no Angular 20. Ele define as estruturas das telas que posteriormente serão prototipadas e desenvolvidas.

## 1. Hierarquia de Telas (Screen Flows)

A plataforma será composta por quatro fluxos principais de experiência, cada um focado em uma persona e ambiente específico.

### 1.1 Mobile do Empreiteiro (Criação de Demandas)
**Objetivo:** Permitir ao empreiteiro solicitar maquinário no campo de forma ágil, com o mínimo de digitação possível e campos focados na operação em campo.

*   **View Inicial:** Lista das chamadas (demandas) ativas daquele empreiteiro ("Acompanhar minhas solicitações").
*   **Formulário de Nova Demanda:** 
    *   Dropdown de Serviços (baseado no módulo Machinery Link).
    *   Opção de `dataAgendada` ou "O mais rápido possível" (`urgencia`).
    *   Geolocalização capturada automaticamente (ou seleção de praça/quadra/lote via UI adaptável a dedos grandes).
*   **Feedback Visual:** Indicador de estado para saber se a supervisão já aprovou o pedido ou se está pendente.

#### Cancelamento de demanda própria em `PENDENTE`

O empreiteiro pode cancelar demandas da sua autoria enquanto estas estiverem no estado `PENDENTE` — sem aprovação administrativa — conforme autoriza `machinery:demanda:cancel` (condição [4] do RBAC — ver `docs/SPEC/04-rbac-permissoes.md`).

**Fluxo:**

1. Na **lista de demandas ativas** (*"Acompanhar minhas solicitações"*), cada card de demanda em estado `PENDENTE` exibe o botão **"Cancelar"** (ícone de X, cor neutra, posicionado no canto superior direito do card).
2. O toque no botão abre o **Modal de Cancelamento** contendo:
   - Identificação resumida da demanda (número/ID + nome do serviço solicitado)
   - Campo de texto **"Justificativa"** — obrigatório, mínimo 10 caracteres
   - Botão **"Confirmar cancelamento"** — habilitado somente após justificativa válida
   - Botão **"Voltar"** — fecha o modal sem executar nenhuma ação
3. Ao confirmar:
   - Chamada de API: `PATCH /demandas/:id` com ação `cancel` e justificativa no payload
   - Demanda transita `PENDENTE → CANCELADA`
   - Card desaparece da lista ativa; Toast de confirmação exibido: *"Demanda #[ID] cancelada."*
4. **Restrição de estado:** o botão "Cancelar" é renderizado **somente** para demandas em `PENDENTE`. Para demandas em `EM_ANDAMENTO`, `CONCLUIDA` ou `CANCELADA`, o empreiteiro não visualiza a opção de cancelamento.

> **DEC-013:** Justificativa obrigatória (mínimo 10 caracteres), alinhada à exigência de trilha auditável de `REQ-ACE-006`. O componente `ActionButton` aplica a guard de permissão RBAC — demandas de autoria de terceiros não exibem o botão.

### 1.2 Mobile do Operador (Execução no Campo)
**Objetivo:** Foco absoluto na demanda de maior prioridade. O operador não escolhe demandas, apenas segue a fila imposta pelo algoritmo de SLA.

*   **Tela Inicial (Check-in Diário):** Se for o início do turno, uma tela bloqueante para realizar o check-in na base.
*   **Card de Demanda Ativa Principal:**
    *   Exibe *apenas* a demanda atual / próxima da fila (`EM_ANDAMENTO` ou a primeira `PENDENTE`).
    *   Dados da demanda: Local, Serviço, Empreiteiro solicitante.
    *   Botões de Ação Dinâmicos: "Cheguei ao Local", "Pausar", "Concluir" variando dependendo do estado atual da demanda.
    *   > **Fase 2:** Botão "Iniciar Deslocamento" removido do MVP — funcionalidade de rastreamento de deslocamento será endereçada em iteração futura.
*   **Lista de Fila (Opcional/Secundária):** Permite ver "o que vem pela frente" apenas com caráter informativo, sem poder de escolha.

#### Notificação de nova demanda: fila vazia vs. fila ativa

**Rastreio PRD:** `REQ-JOR-004`, `REQ-FUNC-013`

O comportamento ao receber uma nova demanda difere conforme o estado atual da fila do operador:

**Cenário A — Fila vazia** (início do expediente ou conclusão de todas as demandas anteriores):

- O sistema exibe um **pop-up de notificação** de tela cheia (sobreposto à view de fila).
- O dispositivo dispara **alerta sonoro e vibração** para garantir percepção mesmo sem a tela ativa.
- Conteúdo do pop-up:
  - Serviço solicitado e localização da demanda.
  - Botão primário **"Iniciar Agora"** — demanda transita para `EM_ANDAMENTO`; pop-up fecha e card ativo é exibido.
  - Botão secundário **"Iniciar Depois (Perfilar)"** — demanda permanece em `PENDENTE`; pop-up fecha e operador retorna à tela de fila com o card da demanda no topo.
  - **Sem botão de recusa** — o cancelamento, quando necessário, segue o fluxo padrão (`REQ-FUNC-009`).

**Cenário B — Fila com demandas ativas:**

- Nenhum pop-up é exibido.
- A nova demanda entra diretamente na fila, reordenada pelo motor de score.
- A próxima demanda da fila permanece em **card expandido** com ação de início visível e acessível.

**Visibilidade no dashboard (`AdminOperacional`):**

- Operadores com fila vazia que receberam demanda mas não iniciaram ficam sinalizados no dashboard (indicador visual de inatividade).
- Não há automação de escalação — o contato é manual (ex.: rádio).

### 1.3 Dashboard Web Subordinado/Supervisor
**Objetivo:** Sala de controle. Visão macro, monitoramento de SLAs e reordenação (Blindagem).

*   **View de Fila (Kanban-style ou Tabela de Alta Densidade):**
    *   Listagem em tempo real (utilizando Signals/RxJS) de todas as demandas e frentes de trabalho.
    *   Forte apelo a UI de SLA: Chips de prioridade (`Baixa`, `Alta`, `Crítica`), cores mudando para amarelo/vermelho quando o SLA está em violação.
*   **Efeito Blindagem (Drag & Drop):** Interface de reordenação visual para sobrepor o algoritmo temporariamente em casos de prioridade no campo ou realocações dinâmicas.
*   **Aprovação & Resolução de Cancelamentos:** Cards/Modais rápidos (Approval Inbox) para aprovar novas demandas do empreiteiro ou avaliar justificativas de quebra/pausas dos operadores.
*   **Indicador de Operador Inativo** (`REQ-FUNC-013`): na visão de operadores (tabela ou Kanban), a linha de cada operador com fila não vazia e sem demanda em `EM_ANDAMENTO` exibe um **badge de alerta** âmbar (ex.: *"Parado"* ou ícone de relógio) enquanto a demanda `PENDENTE` mais antiga da fila ultrapassar um limiar configurável sem iniciada (sugestão MVP: 5 minutos). O badge desaparece assim que o operador inicia a primeira demanda. Não há automação de escalação — o `AdminOperacional` aciona contato manual (ex.: rádio) ao identificar o badge.

### 1.4 Portal Login FGR Interno (Web)
**Objetivo:** Hub seguro de entrada para recursos gerenciais internos, acesso logado.

*   **Tela de Login:** Autenticação padrão com branding da FGR (suporte a MFA/SSO).
*   **App Shell / Hub:** Após logar, o usuário visualiza o menu global de módulos FGR Ops, acessando dali a aplicação específica do *Machinery Link* (Dashboard). Permite troca de contextos contextuais baseada nos perfis mapeados no RBAC (`docs/SPEC/04-rbac-permissoes.md`).

---

## 2. Mapeamento Visual de Estados (State-to-UI Mapping)

Como cada transição formal da Máquina de Estados se reflete na tela (aplicando as decisões do Angular 20):

| Estado da Demanda | Alteração Visual na UI do Empreiteiro (Mobile) | Alteração Visual na UI do Operador (Mobile) | Alteração Visual Supervisor (Dashboard) |
| --- | --- | --- | --- |
| `AGENDADA` | Card exibido na lista com indicador *"Agendada"* e data/hora prevista; botão **"Cancelar"** visível apenas para demandas da própria autoria. | Não visível — demandas `AGENDADA` não aparecem na fila do operador até a transição automática para `PENDENTE`. | Listada em aba separada de agendamentos com data/hora alvo; ações disponíveis para `AdminOperacional`: **"Antecipar"** e **"Cancelar"**. |
| `PENDENTE` | Card exibido na lista com botão **"Cancelar"** visível (apenas demandas da própria autoria). | Mostrado como próxima tarefa se a fila permitir. | Entra na fila ativa ranqueada por cor de SLA. |
| `EM_ANDAMENTO` | Card exibe indicador *"Em andamento"*; botão "Cancelar" **não exibido**. | Card Expandido bloqueante. Ações visíveis: *"Pausar"*, *"Concluir"*, *"Cancelar"* (com justificativa obrigatória). | Exibe crachá do operador responsável piscando / indicador ativo verde. |
| `PAUSADA` *(MVP — ver REQ-FUNC-011)* | Card exibe indicador *"Pausada"*; sem ação disponível para o empreiteiro. | Formulário para registrar o MOTIVO da pausa preenchido previamente. | Ícone Amarelo de Alerta. Fila recalcula as próximas tarefas para a máquina do operador. |
| `RETORNADA` | Card exibe indicador *"Retornando à fila"*; sem ação disponível para o empreiteiro. | Demanda não aparece na fila do operador — estado transitório automático aguardando retorno a `PENDENTE`. | Badge laranja *"RETORNADA"* na linha da demanda; sistema atualiza automaticamente para `PENDENTE` sem intervenção administrativa. |
| `CONCLUIDA` | Card move-se para histórico de solicitações encerradas. | Card sai da view atual e histórico atualiza numeração de meta diária. | Card ganha status verde sólido e move-se para aba "Auditoria" ou de histórico. |
| `CANCELADA` | Card desaparece da lista ativa; Toast: *"Demanda #[ID] cancelada."* | Card desaparece; feedback discreto via Toast *("Demanda #123 cancelada")*. | Riscado/Arquivado em vermelho na visão de encerramentos do dia. |

---

## 3. Componentes-Chave & Padrões Angular 20

Para alcançar a experiência ideal e escalável solicitada para toda a suíte FGR Ops Web, aplicaremos:

1.  **Componentes Reativos baseados em Signals:**
    Implementação pesada do paradigma Zoneless (`providedIn: 'root'`) suportado no Angular 20.
    As reordenações de fila de demandas devem ocorrer sem *flicker* usando Signals vinculados a coleções (`signal<Demand[]>`).

2.  **Sistema de Formulários Validados:**
    Utilizaremos Reactive Forms, integrando a tipagem estrita com Zod ou Valibot (alinhado a DTOs de Backend) para os pedidos no "Mobile Empreiteiro" e os formulários de "Justificativa de Pausa".

3.  **Alertas de SLA / Status Indicators (Badges):**
    Componentes granulares puramente CSS com variância controlada via input de data binding. Evitaremos UI genéricas; as cores seguirão a importância do negócio (Ex: `status-danger` para SLA corrompido, `status-info` para aguardando).

4.  **Botões de Ação Contextuais:**
    Componente visual `ActionButton` que consome o guard de permissões (RBAC). Se a demanda não pode ser cancelada pelo perfil logado, ou se a State Machine não permitir, o CSS de `disabled` entra automaticamente.

---
