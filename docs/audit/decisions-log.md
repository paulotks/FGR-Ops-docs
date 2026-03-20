# Decisions Log — Fase 0 (Triagem de produto)

Este registo centraliza as decisões de produto necessárias antes das correções de PRD/SPEC das fases seguintes.

## Como usar

- `Data`: data da decisão (AAAA-MM-DD).
- `Participantes`: nomes ou papéis que tomaram a decisão.
- `Decisão`: opção escolhida (A/B/C... ou texto curto).
- `Justificação`: racional de negócio e impacto esperado.
- `Achados resolvidos`: IDs marcados como resolvidos após aplicação e re-auditoria.
- `Estado`: `Pendente` até decisão formal; depois `Decidido`.

---

## DEC-001 — Regra Zero vs filtros (`operadorAlocadoId`)

-- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operações, Stakeholders de Negócio
- **Contexto:** definir se `operadorAlocadoId` sobrepõe hard filters ou se deve respeitá-los.
- **Opções em análise:**
  - A) `operadorAlocadoId` sobrepõe hard filters.
  - B) `operadorAlocadoId` respeita hard filters.
  - C) Comportamento híbrido condicionado por estado/regra.
- **Decisão:** C) Comportamento híbrido. Em criação manual por `AdminOperacional`/`UsuarioInternoFGR`, `operadorAlocadoId` pode direcionar demanda para qualquer operador, inclusive fora da zona, como exceção explícita e auditável. Essa alocação sobrepõe as regras automáticas de distribuição/elegibilidade (jurisdição, proximidade e balanceamento), mas não remove o motor de priorização da fila.
- **Justificação:** O motor automático continua como padrão de eficiência operacional. A alocação manual permanece como exceção de gestão para cenários reais de operação. A ordem da fila do operador é usada como organização recomendada de atendimento e não como bloqueio rígido de execução, permitindo ajustes operacionais em campo (ex.: despacho por rádio), com rastreabilidade.
- **Nota MVP:** Na tela de alocação do `UsuarioInternoFGR`, deve existir alerta visual indicando operadores fora da zona definida no momento da seleção. Esta feature é importante para usabilidade e redução de erro, mas não é prioridade para o MVP.
- **Achados resolvidos:** `CROSS-M04-001`, `CROSS-M06-001`, `SPEC-M04-001`, `SPEC-M06-001`, `PRD-M04-002`, `PRD-M06-002`
- **Aplicação (Fase 1.1 — 2026-03-20):**
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-002` qualificado como fluxo automático com excepção explícita para `operadorAlocadoId`; `REQ-FUNC-006` documenta modelo híbrido e ordem recomendada.
  - `PRD/05-criterios-aceite.md`: `REQ-ACE-003` reescrito com terminologia canónica (`operadorAlocadoId`), dois cenários Gherkin (adjacência vs alocação manual; excepção auditável fora da zona).
  - `SPEC/03-fila-scoring-estados-sla.md`: Regra Zero documenta DEC-001, Hard Filter explicita isenção para alocação manual, nota de rastreio alinhada, regra de conflito actualizada.
  - Artefactos regenerados: `M04/consolidated.json`, `M04/traceability.csv`, `M04/traceability-stub.md`, `M06/consolidated.json`, `M06/traceability.csv`, `M06/traceability-stub.md`.

## DEC-002 — Cancelamento automático vs revisão administrativa

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operações, Logística, Stakeholders de Negócio
- **Contexto:** alinhar política para cancelamento/revisão (auto-aprovação em 24h vs revisão humana).
- **Opções em análise:**
  - A) Auto-aprovação em 24h sem intervenção humana.
  - B) Revisão administrativa obrigatória antes de cancelamento.
  - C) Modelo misto com critérios de exceção.
- **Decisão:** A) Auto-aprovação sem intervenção humana, com encerramento por estouro de SLA no fim do expediente da obra. O horário de expediente é parametrizável por obra (ex.: 06h-17h), e cada obra pode manter a própria janela operacional.
- **Justificação:** A decisão privilegia fluidez operacional e redução de backlog administrativo, centralizando o encerramento automático no marco de fim de expediente de cada obra em vez de prazo fixo absoluto. O processo mantém governança por exigir rastreabilidade explícita do motivo de encerramento por SLA estourado e visibilidade gerencial para revisão no dia útil seguinte.
- **Nota MVP:** O cancelamento automático deve gravar trilha auditável obrigatória com origem "estouro de SLA no fim do expediente", ator de sistema e timestamp. `UsuarioInternoFGR`/`AdminOperacional` devem ter visão dedicada no dia seguinte para revisão pós-facto e ação corretiva/operacional quando necessário.
- **Achados resolvidos:** `CROSS-M06-002`, `SPEC-M03-003`, `SPEC-M06-003`

## DEC-003 — Fonte canónica para `REQ-MET-002`

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operacoes, Engenharia, Dados/BI, Stakeholders de Negocio
- **Contexto:** definir onde fica o contrato analítico canónico de "operadores ativos na folha da quinzena".
- **Opções em análise:**
  - A) PRD como fonte canónica; SPEC referencia implementação.
  - B) SPEC como contrato canónico técnico; PRD aponta para SPEC.
  - C) Contrato dividido por camadas (PRD definição de negócio, SPEC definição operacional).
- **Decisão:** C) Contrato dividido por camadas. O PRD fica como fonte canonica da intencao de negocio da metrica (`REQ-MET-002`), enquanto a SPEC fica como fonte canonica do contrato operacional de medicao (formula, denominador, regras de elegibilidade, janela temporal e evidencias auditaveis).
- **Justificação:** A arquitetura tatica exige separacao clara de responsabilidades entre camada de negocio e camada operacional. Esta decisao preserva legibilidade para stakeholders e garante precisao tecnica para implementacao e auditoria, eliminando a ambiguidade atual da trilha PRD->SPEC e fechando a lacuna do denominador "operadores ativos na folha da quinzena".
- **Nota MVP:** Criar secao unica na SPEC para `REQ-MET-002` com definicao formal do denominador, regra de janela da quinzena, timezone, criterios de inclusao/exclusao, politica de deduplicacao por operador e artefato de validacao. Atualizar o PRD para referenciar explicitamente essa secao.
- **Achados resolvidos:** `CROSS-M07-001`, `SPEC-M07-002`, `PRD-M07-001`

## DEC-004 — Política de palavra-passe `REQ-NFR-007`

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operações, Segurança, Engenharia, Stakeholders de Negócio
- **Contexto:** fixar critérios mínimos da política de palavra-passe e local de documentação canónica.
- **Opções em análise:**
  - A) Definir critérios mínimos em PRD e detalhe técnico em SPEC.
  - B) Definir política completa em SPEC e manter PRD de alto nível.
  - C) Definir política completa em PRD e referenciar SPEC apenas para implementação.
- **Decisão:** A) Definir critérios mínimos em PRD e detalhe técnico em SPEC, com política segmentada por perfil. Para perfis de Campo (`Empreiteiro` e `Operador`), adotar autenticação simplificada no app mobile (`Usuário + PIN`) com controles compensatórios de segurança. Para perfis Administrativos/Suporte (demais perfis), manter política de palavra-passe forte conforme `REQ-NFR-007` (mínimo de 8 caracteres, classes obrigatórias e bloqueio de reutilização das últimas 3).
- **Justificação:** A segmentação equilibra usabilidade operacional em campo e segurança corporativa nos perfis de retaguarda. O PRD permanece como fonte dos critérios mínimos e da regra por perfil, enquanto a SPEC torna-se fonte canónica do contrato técnico de autenticação (fluxos, lockout, rate limiting por endpoint/perfil, auditoria e gestão de sessão), fechando a lacuna bloqueante identificada em `SPEC-M05-002`.
- **Nota MVP:** Para login de Campo com `Usuário + PIN`, implementar no mínimo: limite de tentativas com bloqueio temporário progressivo, resposta de erro não enumerável, trilha auditável de autenticação e política de sessão curta. A SPEC deve explicitar os parâmetros operacionais.
- **Achados resolvidos:** `SPEC-M05-002`
