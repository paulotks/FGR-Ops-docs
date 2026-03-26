---
id: 07-design-ui-logica
title: Logica de Interface e UX (Angular 20)
area: UI/UX e Frontend
---

# Design de UI e Lógica de Interface

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

### 1.2 Mobile do Operador (Execução no Campo)
**Objetivo:** Foco absoluto na demanda de maior prioridade. O operador não escolhe demandas, apenas segue a fila imposta pelo algoritmo de SLA.

*   **Tela Inicial (Check-in Diário):** Se for o início do turno, uma tela bloqueante para realizar o check-in na base.
*   **Card de Demanda Ativa Principal:**
    *   Exibe *apenas* a demanda atual / próxima da fila (`EM_EXECUCAO` ou a primeira `PENDENTE_OPERADOR`).
    *   Dados da demanda: Local, Serviço, Empreiteiro solicitante.
    *   Botões de Ação Dinâmicos: "Iniciar Deslocamento", "Cheguei ao Local", "Pausar", "Concluir" variando dependendo do estado atual da demanda.
*   **Lista de Fila (Opcional/Secundária):** Permite ver "o que vem pela frente" apenas com caráter informativo, sem poder de escolha.

### 1.3 Dashboard Web Subordinado/Supervisor
**Objetivo:** Sala de controle. Visão macro, monitoramento de SLAs e reordenação (Blindagem).

*   **View de Fila (Kanban-style ou Tabela de Alta Densidade):**
    *   Listagem em tempo real (utilizando Signals/RxJS) de todas as demandas e frentes de trabalho.
    *   Forte apelo a UI de SLA: Chips de prioridade (`Baixa`, `Alta`, `Crítica`), cores mudando para amarelo/vermelho quando o SLA está em violação.
*   **Efeito Blindagem (Drag & Drop):** Interface de reordenação visual para sobrepor o algoritmo temporariamente em casos de prioridade no campo ou realocações dinâmicas.
*   **Aprovação & Resolução de Cancelamentos:** Cards/Modais rápidos (Approval Inbox) para aprovar novas demandas do empreiteiro ou avaliar justificativas de quebra/pausas dos operadores.

### 1.4 Portal Login FGR Interno (Web)
**Objetivo:** Hub seguro de entrada para recursos gerenciais internos, acesso logado.

*   **Tela de Login:** Autenticação padrão com branding da FGR (suporte a MFA/SSO).
*   **App Shell / Hub:** Após logar, o usuário visualiza o menu global de módulos FGR Ops, acessando dali a aplicação específica do *Machinery Link* (Dashboard). Permite troca de contextos contextuais baseada nos perfis mapeados no RBAC (`docs/SPEC/04-rbac-permissoes.md`).

---

## 2. Mapeamento Visual de Estados (State-to-UI Mapping)

Como cada transição formal da Máquina de Estados se reflete na tela (aplicando as decisões do Angular 20):

| Estado da Demanda | Alteração Visual na UI do Operador (Mobile) | Alteração Visual Supervisor (Dashboard) |
| --- | --- | --- |
| `PENDENTE_APROVACAO` | Invisível para o Operador. | Aparece no Inbox de Aprovação / Fila global com ícone cinza "A Confirmar". |
| `PENDENTE_OPERADOR` | Mostrado como próxima tarefa se a fila permitir. | Entra na fila ativa ranqueada por cor de SLA. |
| `EM_EXECUCAO` | Card Expandido bloqueante. Ações visíveis: *"Pausar"*, *"Finalizar"*. | Exibe crachá do operador responsável piscando / indicador ativo verde. |
| `PAUSADA` | Formulário para registrar o MOTIVO da pausa preenchido previamente. | Ícone Amarelo de Alerta. Fila recalcula as próximas tarefas para a máquina do operador. |
| `CONCLUIDA` | Card sai da view atual e histórico atualiza numeração de meta diária. | Card ganha status verde sólido e move-se para aba "Auditoria" ou de histórico. |
| `CANCELADA` | Card desaparece; feedback discreto via Toast *("Demanda #123 cancelada")*. | Riscado/Arquivado em vermelho na visão de encerramentos do dia. |

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
