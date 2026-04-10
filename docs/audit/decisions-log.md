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
- **Aplicação (Fase 1.2 — 2026-03-20):**
  - `PRD/05-criterios-aceite.md`: `REQ-ACE-006` reescrito — título da secção actualizado para "Cancelamento de demandas em campo e encerramento por SLA"; requisito reformulado para auto-encerramento por estouro de SLA no fim do expediente parametrizável por obra; 3 cenários Gherkin: transição para `PENDENTE_APROVACAO`, encerramento automático no fim do expediente, revisão pós-facto no dia útil seguinte.
  - `SPEC/03-fila-scoring-estados-sla.md`: Fluxo `PENDENTE_APROVACAO` actualizado — prazo de 24h substituído por encerramento no fim do expediente da obra (parametrizável); trilha auditável obrigatória com campos `origem`, `ator`, `timestamp`, `motivo`; visão dedicada de revisão pós-facto para `UsuarioInternoFGR`/`AdminOperacional`; referência a DEC-002.
  - Referências cruzadas corrigidas em `PRD/02-jornada-usuario.md`, `PRD/03-requisitos-funcionais.md`, `SPEC/01-modulos-plataforma.md` e `SPEC/03-fila-scoring-estados-sla.md` (novo anchor da secção).
  - Artefactos regenerados: `M03/consolidated.json`, `M03/traceability.csv`, `M03/traceability-stub.md`, `M06/consolidated.json`, `M06/traceability.csv`, `M06/traceability-stub.md`.

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
- **Aplicação (Fase 1.5 — 2026-03-20):**
  - `SPEC/06-definicoes-complementares.md`: Adicionada secção "Contrato analítico `REQ-MET-002` — Adoção e engajamento operacional" com sete subsecções: Fórmula (numerador = operadores distintos com pelo menos 1 acção; denominador = operadores activos na folha da quinzena), Janela temporal da quinzena (Q1: 1-15, Q2: 16-fim do mês, timezone `America/Sao_Paulo`), Critérios de inclusão/exclusão (tabela com 6 cenários: admissão, desligamento, transferência, férias/licença), Política de deduplicação (contagem única por `User.id`+`obraId`, timestamp de origem offline), Fonte do denominador e integração (contrato mínimo com RH/folha: endpoint, payload, reconciliação quinzenal), Artefato de validação (tabela com 7 campos auditáveis, acessível via painel administrativo). `REQ-MET-002` adicionado ao rastreio PRD do ficheiro.
  - `PRD/06-metricas-riscos.md`: Referência SPEC de `REQ-MET-002` corrigida — apontava para `01-modulos-plataforma.md#modulo-machinery-link-mvp` (fora da paridade oficial de M07); agora aponta para `06-definicoes-complementares.md#contrato-analitico-req-met-002`.
  - Artefactos regenerados: `M07/consolidated.json`, `M07/traceability.csv`, `M07/traceability-stub.md`.

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
- **Aplicação (Fase 1.4 — 2026-03-20):**
  - `SPEC/00-visao-arquitetura.md`: Adicionada ADR D6 (Política de Autenticação e Palavra-passe — segmentação por perfil) com três subsecções: 6.1 Perfis de Campo (Empreiteiro, Operador) com autenticação simplificada por Usuário+PIN (lockout progressivo, sessão curta de 12h, trilha auditável, troca a cada 90 dias, hash bcrypt); 6.2 Perfis Administrativos/Suporte com palavra-passe forte (8 caracteres mínimos, 4 classes obrigatórias, bloqueio de reutilização das últimas 3, lockout de 15 min, troca a cada 180 dias); 6.3 Regras transversais (rate limiting por endpoint/perfil, gestão de sessão com idle timeout de 30 min para campo, tabela `AuthAuditLog`). Princípios arquitecturais (§1) actualizados para referenciar D6.
  - `PRD/04-requisitos-nao-funcionais.md`: `REQ-NFR-007` actualizado — título alterado para "Política de autenticação segmentada por perfil"; texto reformulado para documentar dois grupos (Campo: Usuário+PIN com controlos compensatórios; Administrativo: palavra-passe forte); referência SPEC apontada para novo anchor `#politica-autenticacao-senha`.
  - Artefactos regenerados: `M05/consolidated.json`, `M05/traceability.csv`, `M05/traceability-stub.md`.

## DEC-005 — Localizacao obrigatoria, locais externos e ponto de origem (`REQ-JOR-001`)

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operacoes, Stakeholders de Negocio
- **Contexto:** Alinhar o modelo de localizacao da solicitacao do empreiteiro com a realidade operacional de obras de condominios horizontais, infraestrutura e casas. O requisito original definia `Quadra`/`Lote` como opcionais e nao distinguia servicos de execucao local de servicos de transporte de material.
- **Opcoes em analise:**
  - A) Manter Quadra/Lote opcionais; localizacao generica.
  - B) Tornar Quadra/Lote obrigatorios; criar entidade para locais externos; tipificar servicos de transporte.
  - C) Modelo generico de "ponto de localizacao" sem distincao.
- **Decisao:** B) Localizacao obrigatoria com dois modos. O empreiteiro seleciona obrigatoriamente **Quadra/Lote** ou **Local Externo** (Portaria, Pulmao, Garagem, etc.). O `SetorOperacional` e derivado automaticamente. A filtragem mutua entre Servico e Maquinario melhora a UX ao restringir opcoes invalidas. *(Nota: o escopo de transporte de material — `exigeTransporte`, `PontoOrigem` — foi subsequentemente revisto por DEC-006 e adiado para pos-MVP.)*
- **Justificacao:** A obrigatoriedade de Quadra/Lote reflete o fluxo real do empreiteiro em campo. Locais como Portaria, Pulmao e Garagem precisam ser endereçaveis no sistema sem pertencer a malha de Quadra/Lote. A filtragem mutua entre Servico e Maquinario melhora a UX ao restringir opcoes invalidas.
- **Nota MVP:** A UX deve oferecer alternancia simples entre Quadra/Lote e Local Externo na interface de solicitacao.
- **Aplicacao (2026-03-20):**
  - `PRD/02-jornada-usuario.md`: `REQ-JOR-001` reescrito — localizacao obrigatoria (Quadra/Lote ou Local Externo), `SetorOperacional` derivado, filtragem mutua Servico/Maquinario, material e destino opcionais, descricao complementar recomendada para movimentacao.
  - `SPEC/01-modulos-plataforma.md`: Capacidade #1 (Solicitacao) actualizada para reflectir novo fluxo com dois modos de localizacao, material e destino opcionais.
  - `SPEC/02-modelo-dados.md`: Adicionada entidade `LocalExterno`; `Demanda` expandida com atributos de localizacao (`localTipo`), material e destino opcionais, e `descricaoAdicional`. `REQ-JOR-001` adicionado ao rastreio PRD.

## DEC-006 — Revisao do escopo de transporte de material no MVP (`REQ-JOR-001`)

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Logistica de campo, Operacoes
- **Contexto:** Validacao de campo com auxiliar de Logistica revelou que o fluxo real de movimentacao de massas (Grunt, Concreto, etc.) difere do modelo de entrega de material desenhado em DEC-005. Na pratica, o empreiteiro nao solicita massas como pedido de material externo — os materiais ja se encontram na frente de obras, tipicamente em caixa d'agua dentro ou na frente do lote. As demandas sao para o operador de maquinas **movimentar** a massa existente (ex.: subir grunt para laje, descer massa, levar para lote ao lado). O fluxo actual no sistema legado utiliza: Servico=Movimentacao, Equipamento=Munck, Material=Grunt, Localizacao=Quadra/Lote de origem, Destino=Quadra de Destino (geralmente interno ao lote), Descricao=texto livre.
- **Opcoes em analise:**
  - A) Manter `exigeTransporte`, `PontoOrigem` e fluxo de entrega formal no MVP.
  - B) Adiar o fluxo de entrega formal para pos-MVP; no MVP tratar movimentacao de massas como demanda regular com material e destino opcionais e descricao em texto livre.
  - C) Remover completamente o conceito de entrega de material do roadmap.
- **Decisao:** B) Adiar entrega formal de material para pos-MVP. No MVP, servicos de movimentacao de massas sao tratados como demandas regulares: o empreiteiro informa localizacao (Quadra/Lote ou Local Externo), seleciona servico e equipamento com filtragem mutua, opcionalmente seleciona material (para `fator_material`) e informa destino (Quadra/Lote), e detalha a operacao no campo de descricao. As entidades `PontoOrigem`, a flag `exigeTransporte` no `Servico` e os campos polimorficos de origem na `Demanda` ficam adiados para Fase 2, onde poderao ser reaproveitados para um servico de entrega de material de origem externa.
- **Justificacao:** O material (massas, grunt, concreto) ja se encontra na frente de obras e nao precisa de logistica de entrega no MVP. O fluxo real e de movimentacao local, adequadamente atendido pelo formulario existente com descricao em texto livre. A implementacao de entrega formal de material (`PontoOrigem`, `exigeTransporte`) nao e inutil — e reaproveitavel em fase posterior para cenarios de entrega de material de origens externas (centrais, usinas) — mas adiciona complexidade desnecessaria ao MVP.
- **Nota MVP:** A UI do empreiteiro permanece com o fluxo simples: localizacao + servico/equipamento + material (opcional) + destino (opcional) + descricao.
- **Aplicacao (2026-03-20):**
  - `PRD/02-jornada-usuario.md`: `REQ-JOR-001` revisto — subsecao "Servicos com transporte de material" substituida por "Material e destino (opcionais)" com nota sobre movimentacao de massas e adiamento de entrega formal; descricao complementar recomendada para movimentacao.
  - `SPEC/01-modulos-plataforma.md`: Capacidade #1 simplificada — removidas referencias a `exigeTransporte` e `PontoOrigem`; material e destino descritos como opcionais.
  - `SPEC/02-modelo-dados.md`: Removida entidade `PontoOrigem`; removidos `exigeTransporte` e `pontoOrigemPadraoId` do `Servico`; `Demanda` simplificada (removidos campos polimorficos de origem; mantidos `materialId` e `destinoQuadraId`/`destinoLoteId` como opcionais).
  - `SPEC/06-definicoes-complementares.md`: `PontoOrigem` removido da tabela de rastreabilidade.
  - `SPEC/05-backlog-mvp-glossario.md`: Adicionado item "Entrega formal de material" aos adiamentos para Fase 2.

## DEC-009 — Reintrodução de `exigeTransporte` no MVP e modelo de cadastro de Serviços

- **Estado:** Decidido
- **Data:** 2026-03-26
- **Participantes:** Produto, Operações
- **Contexto:** Revisão de requisitos identificou quatro lacunas no modelo de `Servico`: (1) ausência do campo `descricao`; (2) vínculo incorreto de `Servico` com instância `Maquinario` em vez de `TipoMaquinario` — inconsistência entre modelo ER e contrato de API; (3) ausência da flag `exigeTransporte`, que havia sido adiada em DEC-006 por estar acoplada ao fluxo de entrega formal de material externo (`PontoOrigem`); (4) ausência de regra para destino obrigatório em serviços de transporte.
- **Opções em análise:**
  - A) Manter `exigeTransporte` adiado (DEC-006) e tratar transporte apenas via descrição livre.
  - B) Reintroduzir `exigeTransporte` no MVP com escopo restrito a transporte interno da obra (sem `PontoOrigem`), vinculado ao cadastro de `Servico`.
- **Decisão:** B) `exigeTransporte` reintroduzido no MVP com escopo distinto do que foi adiado em DEC-006. A flag indica que o serviço envolve deslocamento de material ou equipamento **dentro da obra** (não entrega de material externo). Quando `exigeTransporte = true`, a abertura de demanda exige destino (`destinoQuadraId` + `destinoLoteId`) ou declaração de **Transporte Interno** (`transporteInterno = true`), onde destino = origem. `PontoOrigem` e entrega formal de material externo permanecem adiados para Fase 2.
- **Justificação:** A necessidade operacional de rastrear para onde o material ou equipamento será deslocado é real no MVP e não depende de `PontoOrigem`. A separação entre "transporte interno à obra" (MVP) e "entrega de material de origem externa" (Fase 2) elimina a ambiguidade de DEC-006 sem aumentar o escopo da entrega.
- **Achados resolvidos:** Lacunas identificadas na revisão de 2026-03-26: `descricao` ausente em `Servico`, vínculo `Servico.maquinarioId` incorreto, `exigeTransporte` ausente, comportamento de destino obrigatório não documentado.
- **Aplicação (2026-03-26):**
  - `SPEC/02-modelo-dados.md`: Entidade `Servico` atualizada — adicionados `descricao` e `exigeTransporte`; FK alterada de `maquinarioId` → `tipoMaquinarioId`. Entidade `Demanda` atualizada — adicionado `transporteInterno`; `destinoQuadraId`/`destinoLoteId` documentados como condicionalmente obrigatórios. Diagrama ER e relacionamentos corrigidos: `TipoMaquinario ||--o{ Servico` substitui `Maquinario ||--o{ Servico`.
  - `PRD/02-jornada-usuario.md`: `REQ-JOR-001` atualizado — seção "Material e destino" documenta obrigatoriedade condicional e opção de Transporte Interno.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-003` expandido com campos mínimos do cadastro de `Servico` e vínculo com `TipoMaquinario`.
  - `SPEC/08-api-contratos.md`: CRUD de serviços adicionado (`POST`, `PATCH`, `DELETE /obras/:id/servicos`); `GET /obras/:id/servicos` atualizado com `exigeTransporte`; `CreateDemandaDto` atualizado com `transporteInterno` e validação condicional; erro `DEM-005` adicionado.

## DEC-010 — Modelo de cadastro de TipoMaquinario e Maquinario

- **Estado:** Decidido
- **Data:** 2026-03-26
- **Participantes:** Produto, Operações
- **Contexto:** Revisão dos requisitos de maquinário definiu dois fluxos de cadastro explícitos: (1) tela de tipos de maquinário e (2) tela de maquinários individuais vinculados ao tipo. O modelo existente apresentava lacunas: `TipoMaquinario` sem `descricao`; `Maquinario` sem campo `nome` e com `propriedade` como enum `FGR/Terceiro` insuficiente para identificar a empresa proprietária; campo `porte` no tipo sem uso funcional no MVP.
- **Decisão:** Revisão do modelo para o MVP mínimo funcional:
  - `TipoMaquinario`: adicionar `descricao` (obrigatório); remover `porte` (adiado para Fase 2, sem uso no MVP).
  - `Maquinario`: adicionar `nome` (obrigatório); substituir `propriedade` (enum FGR/Terceiro) por `empresaProprietaria` (texto livre, obrigatório); manter `placa` como campo opcional.
- **Justificação:** O campo `nome` é necessário para exibição no formulário de abertura de demanda (seleção de maquinário). `empresaProprietaria` como texto livre suporta tanto máquinas da FGR quanto de terceiros com identificação nominal da empresa. `placa` permanece para rastreio de máquinas com registro veicular. `porte` não tem impacto funcional no MVP (não influencia score, filtros ou SLA) e pode ser reintroduzido em fase posterior.
- **Aplicação (2026-03-26):**
  - `SPEC/02-modelo-dados.md`: Entidade `TipoMaquinario` — adicionado `descricao`, removido `porte`. Entidade `Maquinario` — adicionado `nome`, substituído `propriedade` por `empresaProprietaria`. Diagrama ER e narrativa atualizados.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-003` expandido com campos explícitos de `TipoMaquinario` e `Maquinario`, menção às telas dedicadas e à filtragem mútua.
  - `SPEC/08-api-contratos.md`: CRUD de `TipoMaquinario` adicionado (`GET /tipos-maquinario`, `POST`, `PATCH`, `DELETE`); CRUD de `Maquinario` completado (`POST`, `PATCH`, `DELETE /obras/:id/maquinarios`); `GET /obras/:id/maquinarios` atualizado com novos campos.
  - `SPEC/04-rbac-permissoes.md`: Permissões `machinery:tipo-maquinario:*` adicionadas.

## DEC-007 — Stack de frontend web: Angular 20 (PWA)

- **Estado:** Decidido
- **Data:** 2026-03-25
- **Participantes:** Produto, Engenharia, Arquitetura
- **Contexto:** alinhar documentacao canonica de plataforma a uma stack de frontend moderna e estavel, substituindo referencias legadas a Next.js e evitando roadmap de Fase 2 prescriptivo em React Native quando a decisao de canal movel ainda e aberta.
- **Opcoes em analise:**
  - A) Manter Next.js como referencia no PRD/SPEC.
  - B) Adotar **Angular** major **20** como baseline do cliente web (`apps/web`), com PWA mobile-first e nota de validacao de patch **20.x** no momento da implementacao.
  - C) Outro framework SPA sem consolidacao de versao.
- **Decisao:** B) **Angular** major **20** como linha estavel do frontend web no monorepo; **baseline canónica** major 20; validar o patch mais recente da serie **20.x** antes de fixar dependencias de build. PWA e requisitos de conectividade/offline permanecem os de `REQ-NFR-002`; roadmap de Fase 2 para experiencia movel nativa permanece deliberadamente neutro quanto a framework (ver SPEC).
- **Justificacao:** Centraliza a versao alvo nos artefactos PRD/SPEC, remove inconsistencia com uma stack ja descontinuada na decisao actual e separa a escolha de framework web da eventual decisao de canal nativo em Fase 2.
- **Nota MVP:** Nenhuma alteracao de escopo funcional; apenas alinhamento de plataforma e documentacao.
- **Achados resolvidos:** *(n/a — decisao arquitectural documental)*
- **Aplicacao (2026-03-25):**
  - `PRD/04-requisitos-nao-funcionais.md`: `REQ-NFR-002` actualizado para Angular 20 com baseline e nota de patch 20.x.
  - `SPEC/00-visao-arquitetura.md`: `apps/web`, principios mobile-first e ADR **D7** alinhados a Angular 20; roadmap Fase 2 sem prescricao de React Native.
  - `docs/traceability.md`: linha `REQ-NFR-002` actualizada com referencia a DEC-007 e D7.

## DEC-008 — Paradigma Zoneless e Signals como padrão de reatividade (Angular 20)

- **Estado:** Decidido
- **Data:** 2026-03-26
- **Participantes:** Produto, Engenharia, Arquitetura
- **Contexto:** Após fixar Angular 20 como baseline (DEC-007), alinhar o padrão de reatividade do frontend para garantir performance adequada na fila de demandas em tempo real e nos indicadores de SLA.
- **Opções em análise:**
  - A) Manter Zone.js como padrão de detecção de mudanças do Angular.
  - B) Adoptar paradigma Zoneless com Signals como unidade primária de estado reativo.
  - C) Abordagem híbrida com Zone.js para componentes existentes e Signals apenas em novos.
- **Decisão:** B) Paradigma **Zoneless** com **Signals** como padrão de reatividade para todos os componentes novos. Coleções de demandas modeladas como `signal<Demand[]>`; RxJS mantido apenas onde a semântica de stream for estritamente necessária (ex.: WebSocket, debounce de input).
- **Justificação:** A reordenação contínua da fila de demandas requer renderização sem *flicker* e sem custo de detecção de mudanças por árvore completa. O paradigma Zoneless com Signals elimina o overhead do Zone.js e reduz ciclos de detecção desnecessários, garantindo responsividade adequada nos dashboards de SLA e nas filas do operador mobile.
- **Achados resolvidos:** *(n/a — decisão arquitectural documental)*
- **Aplicação (2026-03-26):**
  - `docs/SPEC/07-design-ui-logica.md`: §3 documenta implementação Zoneless (`providedIn: 'root'`), Signals para coleções de demandas, Reactive Forms com Zod/Valibot e componente `ActionButton` com guard RBAC integrado.

## DEC-011 — Estado `PAUSADA` na máquina de estados da Demanda (MVP)

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações
- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- **Opções em análise:**
  - A) Remover `PAUSADA` do MVP — simplifica a máquina de estados; pausa seria Fase 2.
  - B) Manter `PAUSADA` no MVP — atende necessidade operacional real de campo; requer formalização das transições e novo REQ.
- **Decisão:** B) Manter `PAUSADA` no MVP. Adicionar transições `EM_ANDAMENTO → PAUSADA` (ação `pausar`, Operador, justificativa obrigatória) e `PAUSADA → EM_ANDAMENTO` (ação `retomar`, Operador) à máquina de estados canônica de `SPEC/03`. Criar `REQ-FUNC-011` no PRD.
- **Justificação:** Operadores em campo precisam pausar demandas por razões operacionais legítimas (aguardar material, interferência de outro equipamento, intervalo obrigatório). Sem `PAUSADA`, seriam forçados a concluir falsamente ou devolver a demanda à fila geral, distorcendo métricas e perdendo a vinculação. O estado `PAUSADA` preserva o vínculo operador-demanda e mantém rastreabilidade auditável com motivo obrigatório.
- **Restrições MVP:**
  - SLA continua correndo durante `PAUSADA` (sem suspensão de timer).
  - Sem limite de tempo de pausa definido no MVP.
  - Motor de fila trata o equipamento como momentaneamente indisponível para novas atribuições automáticas enquanto houver demanda `PAUSADA`.
- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).
- **Aplicação (2026-04-09):**
  - `SPEC/03-fila-scoring-estados-sla.md`: `PAUSADA` adicionado ao diagrama Mermaid com transições `pausar` e `retomar`; linhas correspondentes inseridas na tabela de transições; seção "Fluxo detalhado `PAUSADA`" criada com regras de vínculo, SLA, DemandaLog e comportamento do motor de fila; `REQ-FUNC-011` adicionado ao bloco de Rastreio PRD.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-011` já registrado (nota DEC-011 pendente atualizada como decidida na data acima).

---

## DEC-012 — Papel e posição hierárquica da entidade `Rua` no modelo espacial

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações
- **Contexto:** O item 2 do TODO de correções PRD/SPEC (2026-04-09) exigia definir o papel da entidade `Rua` no domínio: (A) descritiva sem impacto operacional, (B) participante do algoritmo de adjacência, ou (C) entidade de agrupamento puramente visual.
- **Opções em análise:**
  - A) `Rua` como dado descritivo livre em `Quadra` (campo texto, sem entidade própria) — sem FK, sem impacto no motor de fila.
  - B) `Rua` como entidade filha de `Quadra` — FK `ruaId` em `Quadra` — hierarquia Quadra → Rua.
  - C) `Rua` como entidade de agrupamento de `Quadras` — FK `ruaId` em `Quadra` — hierarquia Rua → Quadra.
- **Decisão:** C) `Rua` é entidade de agrupamento **pai de `Quadra`**: uma `Rua` contém múltiplas `Quadras`; `Quadra` carrega `ruaId` (FK nullable). No MVP, `Rua` é **descritiva** — não participa do algoritmo de adjacência nem do score de fila. Sua função primária é referência visual para o usuário localizar máquinas e evitar colisões entre equipamentos.
- **Justificação:** O exemplo operacional "o posto da Quadra X e da Quadra Y estão na Rua Z" prova que a relação correta é `Rua ||--o{ Quadra`, não o inverso. Tratar `Rua` como texto livre (opção A) perderia a capacidade de filtragem e visualização agrupada; tratar como filha de `Quadra` (opção B) inverteria a hierarquia espacial. A opção C reflete a realidade de campo: uma rua de obra tem múltiplas quadras (blocos) às suas margens. O `ruaId` ser nullable preserva compatibilidade com obras que ainda não mapearam ruas. Participação no algoritmo de adjacência fica adiada para Fase 2.
- **Restrições MVP:**
  - `ruaId` é **nullable** em `Quadra` — obra pode funcionar sem ruas cadastradas.
  - `Rua` **não** altera `fator_adjacencia` nem qualquer peso do motor de score no MVP.
  - `Rua` **não** tem permissões RBAC dedicadas no MVP — gerenciada pelo mesmo perfil que gerencia `Quadra` (`AdminOperacional`).
  - Fase 2: avaliar uso de `Rua` como critério de adjacência intermediária (máquinas na mesma rua = `fator_adjacencia` 0.5 por padrão).
- **Achados resolvidos:** TODO-correcoes-prd item 2 (papel da entidade `Rua`).
- **Aplicação (2026-04-09):**
  - `SPEC/02-modelo-dados.md`: entidade `Rua` adicionada ao diagrama ER com campos `id`, `nome`, `obraId`; `ruaId` (nullable) adicionado a `Quadra`; relação `Rua ||--o{ Quadra : "contém"` e `Obra ||--o{ Rua : "contém"` inseridas; texto da seção "Organização espacial" atualizado com papel descritivo de `Rua` no MVP.

---

## DEC-013 — Fluxo de cancelamento de demanda própria pelo Empreiteiro na UI mobile

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações
- **Contexto:** O item 3 do TODO de correções PRD/SPEC (2026-04-09) identificou que a permissão `machinery:demanda:cancel` (condição [4]: autoria + estado `PENDENTE`) estava autorizada no RBAC mas sem representação documentada na UI de campo do empreiteiro em `SPEC/07`.
- **Opções em análise:**
  - A) Botão "Cancelar" direto no card sem justificativa — mais rápido, sem fricção, porém sem trilha auditável.
  - B) Botão "Cancelar" no card + modal com campo de justificativa obrigatória.
- **Decisão:** B) Botão "Cancelar" exibido no card da demanda em `PENDENTE` + Modal de Confirmação com campo de justificativa obrigatório (mínimo 10 caracteres). O botão não é renderizado para demandas em outros estados ou de autoria de terceiros.
- **Justificação:** A justificativa obrigatória alinha-se à exigência de trilha auditável de `REQ-ACE-006` e ao padrão já adotado para outros fluxos de cancelamento no sistema (operadores via `SolicitacaoCancelamento`, admins). Evita cancelamentos acidentais por toque inadvertido e cria registro rastreável para revisão administrativa posterior.
- **Achados resolvidos:** TODO-correcoes-prd item 3 (fluxo de cancelamento do Empreiteiro na UI).
- **Aplicação (2026-04-09):**
  - `SPEC/07-design-ui-logica.md`: subseção "Cancelamento de demanda própria em `PENDENTE`" adicionada em 1.1 com fluxo detalhado; tabela State-to-UI Mapping expandida com coluna do Empreiteiro; `REQ-ACE-006` adicionado ao bloco Rastreio PRD.
  - `PRD/02-jornada-usuario.md`: subseção "Acompanhamento e cancelamento de demanda própria" adicionada em `REQ-JOR-001` com cross-link para SPEC/07.
  - `docs/traceability.md`: `REQ-ACE-006` e `REQ-JOR-001` atualizados para incluir `SPEC/07` como cobertura adicional.

---

## DEC-014 — Fronteira FGR Ops (plataforma) vs Machinery Link (módulo) e sequência de bootstrapping de obra

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações, Arquitetura
- **Contexto:** O item 4 do TODO de correções PRD/SPEC (2026-04-09) identificou que o PRD/SPEC descrevia cadastros e perfis sem deixar claro **onde** cada responsabilidade vive: FGR Ops (plataforma multi-módulo futura) vs Machinery Link (módulo operacional entregue no MVP). O Machinery Link hoje é sistema standalone; no MVP ele é re-platformado como primeiro módulo do FGR Ops. Sem essa separação explícita, a sequência de setup inicial de uma obra ficava ambígua quanto a quem executa cada passo e em qual aplicação.
- **Opções em análise:**
  - A) Tratar tudo dentro do Machinery Link e ignorar a camada FGR Ops no MVP — mais simples, porém cria dívida arquitetural ao introduzir o segundo módulo (almoxarifado, IoT).
  - B) Introduzir novos perfis específicos para FGR Ops (`AdminSistemaFGROps`, `DiretorGlobal`) — formaliza a camada, mas cascateia novos `REQ-RBAC-*` e duplica conceitos já cobertos por `SuperAdmin` e `Board`.
  - C) Manter os perfis atuais e formalizar arquiteturalmente que `SuperAdmin` e `Board` operam na camada FGR Ops (plataforma), enquanto `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` e `Operador` operam na camada Machinery Link (módulo).
- **Decisão:** C) Formalização de duas camadas sem criação de novos perfis. A camada **FGR Ops** (plataforma, cross-tenant) é responsável pelo cadastro de `Obra`, provisão de usuários e ativação de módulos — operada por `SuperAdmin` (papel funcional: "Administrador do Sistema FGR Ops") e `Board` (papel funcional: "Diretor / Gerente de Obra Global"). A camada **Machinery Link** (módulo, tenant-scoped) concentra todos os cadastros operacionais internos à obra e o ciclo de vida de `Demanda` — operada por `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` e `Operador`. O roteamento de login é dual: `SuperAdmin` e `Board` passam pelo shell FGR Ops (seleção de obra → hub de módulos habilitados); os demais perfis entram diretamente na aplicação do módulo. A sequência canônica de 18 passos de bootstrapping fica documentada em `SPEC/01-modulos-plataforma.md#bootstrapping-de-obra`.
- **Justificação:** Os perfis `SuperAdmin` (cross-tenant, único com `core:obra:create`) e `Board` (cross-tenant, estritamente leitura) já existiam na matriz RBAC e cumpriam exatamente o papel de camada de plataforma — não havia ganho em duplicá-los. A decisão reusa a matriz RBAC atual sem quebrar cobertura de auditoria e esclarece o modelo mental para leitores do SPEC. O acesso direto dos perfis de campo ao módulo evita fricção em smartphone (`REQ-NFR-002`, `REQ-OBJ-005`), enquanto o shell FGR Ops fica reservado para os perfis que realmente precisam de visão cross-obra ou cross-módulo. A sequência canônica de bootstrapping com regras de integridade ("obra elegível para criação de demandas apenas quando X, Y, Z estão presentes") destrava a futura implementação do backend ao definir claramente as pré-condições operacionais.
- **Restrições MVP:**
  - Apenas um módulo exibido no hub FGR Ops: `Machinery Link`. O shell é construído para suportar N módulos futuros, mas a lista é hardcoded no MVP.
  - Toggle binário de ativação: uma obra tem ou não tem Machinery Link ativo; não há configuração fina de features no nível plataforma.
  - Painel executivo dedicado para `Board` (com cruzamento de dados entre obras: horas de maquinário, engajamento de operadores, etc.) fica na **Fase 2** como módulo futuro do FGR Ops.
  - Nenhum novo `REQ-RBAC-*` é criado; a matriz de permissões existente já cobre integralmente as duas camadas.
  - Empreiteira (passo #13) e LocalExterno (passo #9) são citados na sequência canônica mas têm entidade e contratos CRUD pendentes de formalização nos itens 6 e 7 do TODO-correcoes-prd.
- **Achados resolvidos:** TODO-correcoes-prd item 4 (sequência de setup inicial de uma obra).
- **Aplicação (2026-04-09):**
  - `SPEC/01-modulos-plataforma.md`: nova seção `## Bootstrapping de obra` com subseções (Arquitetura de duas camadas, Fluxo de autenticação e roteamento, Sequência canônica de cadastros, Regras de integridade, Delimitação FGR Ops ↔ Machinery Link MVP). Bloco Rastreio PRD expandido com `REQ-RBAC-001..003`, `REQ-SCO-001..004`.
  - `docs/traceability.md`: linha de `REQ-SCO-*` e `REQ-RBAC-*` enriquecida com referência à nova seção de bootstrapping.
  - `TODO-correcoes-prd.md`: item 4 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-014; "Próxima disponível" atualizada para DEC-015.

## DEC-015 — FK `setorOperacionalId` em `Quadra` e não-conflito com `Rua`

- **Estado:** Decidido
- **Data:** 2026-04-10
- **Participantes:** Produto, Arquitetura
- **Contexto:** O item 5 do TODO de correções PRD/SPEC (2026-04-09) identificou que o ER de `SPEC/02-modelo-dados.md` não registrava a FK `setorOperacionalId` em `Quadra`, embora o texto de `SPEC/08` e o campo `Demanda.setorOperacionalId` já mencionassem que o setor é derivado automaticamente do `quadraId`. Antes de adicionar a FK era necessário verificar se haveria conflito com a entidade `Rua` (que também agrupa `Quadras`) ou com a relação `SetorOperacional`.
- **Opções em análise:**
  - A) `setorOperacionalId` vai em `Rua`, e `Quadra` herda o setor via join através de `ruaId` — reduz redundância, mas impede obras sem ruas cadastradas de funcionar.
  - B) `setorOperacionalId` vai em `Quadra` diretamente — simétrico ao padrão de `LocalExterno`; `Rua` permanece puramente descritiva e nullable.
  - C) `SetorOperacional` agrupa `Ruas` (não `Quadras`) — exige criar FK em `Rua` e reformular toda a hierarquia espacial.
- **Decisão:** B) `setorOperacionalId` é adicionado diretamente em `Quadra`, como campo obrigatório e não-nulo (com validação de mesma `obraId`). `Rua` não recebe `setorOperacionalId`; mantém-se como agrupador visual opcional (nullable), sem papel no motor de fila (DEC-012). A `Demanda` continua derivando `setorOperacionalId` automaticamente a partir do `quadraId` escolhido — sem input manual do usuário.
- **Justificação:** `Quadra` é a unidade operacional primária de onde o motor de fila obtém a jurisdição de setor. `LocalExterno` já usa o mesmo padrão (FK direta). `Rua` é puramente descritiva no MVP (DEC-012) e seu `ruaId` é nullable em `Quadra`, portanto não pode ser veículo de herança de setor sem criar dependência obrigatória — o que quebraria obras sem ruas cadastradas. A opção B mantém consistência arquitetural, preserva o padrão nullable de `ruaId` e não exige nenhuma alteração na hierarquia espacial existente.
- **Achados resolvidos:** TODO-correcoes-prd item 5 (FK `setorOperacionalId` em `Quadra` no ER).
- **Aplicação (2026-04-10):**
  - `SPEC/02-modelo-dados.md`: campo `setorOperacionalId` adicionado à entidade `Quadra` no diagrama Mermaid; relação `SetorOperacional ||--o{ Quadra : "jurisdição"` adicionada ao ER; regra de integridade documentada na seção "Relacionamentos e regras de integridade".
  - `TODO-correcoes-prd.md`: item 5 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-015; "Próxima disponível" atualizada para DEC-016.

## DEC-016 — Empreiteira global, vínculo Empreiteiro ↔ Empreiteira e modelo de propriedade de Maquinario

- **Estado:** Decidido
- **Data:** 2026-04-10
- **Participantes:** Produto, Arquitetura
- **Contexto:** O item 6 do TODO de correções PRD/SPEC (2026-04-09) exigia formalizar três aspectos inter-relacionados: (a) como o usuário `Empreiteiro` fica vinculado à entidade `Empreiteira`; (b) como o `Maquinario` registra sua propriedade (FGR ou terceirizada); (c) qual é o escopo de `Empreiteira` — por obra ou global. Adicionalmente, foi analisada a necessidade de um vínculo permanente `Maquinario → Operador`.
- **Opções em análise:**
  - Vínculo Empreiteiro: FK `empreiteiraId` diretamente em `User` vs entidade de perfil separada.
  - Propriedade de Maquinario: (A) FK nullable `empreiteiraId` onde `null = FGR`; (B) discriminador explícito `proprietarioTipo` + `empreiteiraId` nullable.
  - Operador em Maquinario: (A) `operadorPadraoId` FK permanente; (B) vínculo apenas via `RegistroExpediente` (dinâmico).
  - Escopo Empreiteira: (A) tenant-scoped (com `obraId`); (B) global (sem `obraId`), reutilizável entre obras e módulos.
- **Decisão:**
  1. **Vínculo Empreiteiro ↔ Empreiteira:** `empreiteiraId` (UUID nullable) adicionado diretamente ao `User`. Campo obrigatório quando `perfil = Empreiteiro`, nulo para os demais perfis. O vínculo é estabelecido pelo `AdminOperacional` na criação do usuário (payload documentado em `SPEC/08`).
  2. **Propriedade de Maquinario:** Opção B — `proprietarioTipo: enum(FGR, EMPREITEIRA)` (obrigatório) + `empreiteiraId: uuid | null` (obrigatório quando `proprietarioTipo = EMPREITEIRA`, nulo quando `FGR`). Campo `empresaProprietaria` (texto livre, DEC-010) removido e supersedido por este modelo estruturado.
  3. **Operador em Maquinario:** Opção B — sem `operadorPadraoId`. O vínculo entre `Maquinario` e `Operador` é sempre dinâmico, gerenciado via `RegistroExpediente` por expediente. Um `operadorPadraoId` permanente criaria inconsistência quando o operador muda de máquina no turno.
  4. **Escopo de Empreiteira:** Global (sem `obraId`). `Empreiteira` é entidade de catálogo reutilizável entre obras e futuros módulos (almoxarifado, IoT etc.). Campos adicionados ao MVP: `cnpj` (opcional; chave única global quando informado, preparado para futura obrigatoriedade), `telefone`, `email`, `responsavel`, `endereco`. A associação implícita a uma obra é derivada via `User` com `perfil = Empreiteiro` e `obraId` correspondente. Relação explícita N:M `Empreiteira ↔ Obra` adiada para Fase 2.
- **Justificação:** FK direta em `User` evita entidade de perfil desnecessária para o MVP. O discriminador `proprietarioTipo` elimina a ambiguidade semântica entre "pertence à FGR" e "sem proprietário definido" que ocorreria com `empreiteiraId = null` sem discriminador. Escopo global preserva integridade referencial quando a mesma construtora terceirizada participar de múltiplas obras — CNPJ como chave única global impede duplicatas semânticas e prepara o terreno para futura reutilização cross-módulo (D4 se aplica internamente ao módulo, mas o catálogo de parceiros de negócio é naturalmente global). O vínculo `Maquinario → Operador` via `RegistroExpediente` é suficiente para relatórios e fila, sem criar rigidez operacional.
- **Achados resolvidos:** TODO-correcoes-prd item 6 (vínculo Empreiteiro ↔ Empreiteira).
- **Aplicação (2026-04-10):**
  - `SPEC/02-modelo-dados.md`: `Empreiteira` promovida a global (removido `obraId`, adicionados `cnpj`/`telefone`/`email`/`responsavel`/`endereco`); `User` recebe `empreiteiraId` nullable; `Maquinario` recebe `proprietarioTipo` + `empreiteiraId`, remove `empresaProprietaria`; relações e regras de integridade atualizadas.
  - `SPEC/08-api-contratos.md`: nova seção CRUD `Empreiteira` (`/empreiteiras`); payloads de criação e atualização de `Maquinario` atualizados; `empreiteiraId` adicionado ao payload de criação de usuário `Empreiteiro`.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-012` criado — CRUD de `Empreiteira` e vínculo com `User (Empreiteiro)`.
  - `docs/PRD/_index.md`, `docs/traceability.md`: atualizados com `REQ-FUNC-012`.
  - `TODO-correcoes-prd.md`: item 6 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-016; "Próxima disponível" atualizada para DEC-017.

---

## DEC-017 — Canal WebSocket como mecanismo único de notificação em tempo real no MVP

- **Data:** 2026-04-10
- **Contexto:** SPEC/03 referenciava "UI push de alta prioridade" e "UI push normal" para os níveis de SLA `MAXIMA` e `ELEVADA`, sem definir o canal técnico. O item 11 do TODO de correções do PRD exigia a especificação do mecanismo — tecnologia, payload, deduplicação e escalação.
- **Decisão:**
  1. **Transporte:** WebSocket (`wss://`) via NestJS Gateway — único canal de eventos em tempo real para o MVP. Não haverá Web Push API (notificações nativas de sistema operacional) nesta fase.
  2. **Justificativa:** WebSocket já era mencionado em SPEC/06 para o sinal `INVALIDATE_QUEUE`. Unificar todos os eventos em um único gateway reduz a complexidade de infraestrutura. Web Push exigiria VAPID keys, service worker de push dedicado e gestão de subscrições por dispositivo — overhead desnecessário para um MVP em que o operador mantém o PWA aberto durante o expediente.
  3. **Eventos canônicos definidos:**
     - `DEMAND_QUEUED` — nova demanda entra na fila do operador (operadores)
     - `SLA_ALERT` — SLA vencido, disparado uma única vez no `slaVencimentoEm` (operadores)
     - `INVALIDATE_QUEUE` — invalida cache local da fila (operadores + admins)
     - `SLA_ESCALATION` — escalação após +5 min (`MAXIMA`) ou +15 min (`ELEVADA`) sem ação (admins + SuperAdmin)
     - `DEMAND_STATUS_CHANGED` — qualquer transição de estado de demanda (admins)
  4. **Deduplicação:** `SLA_ALERT` disparado uma única vez por demanda; estado visual de SLA vencido persiste até transição de estado. `SLA_ESCALATION` não é deduplicado — cada etapa de escalação gera evento distinto.
  5. **Escalação para SuperAdmin:** via mesmo canal WebSocket. Email ou canal externo adiados para Fase 2.
  6. **Vibração PWA:** `DEMAND_QUEUED` com `prioridade = MAXIMA` aciona API Vibration (`[200, 100, 200]`).
  7. **Degradação:** queda do WebSocket ativa o banner offline existente; fila permanece visível via cache stale; reconexão com back-off exponencial (1 s → 2 s → 4 s, máximo 30 s) seguida de reidratação via `GET /operadores/:id/fila`.
- **Achados resolvidos:** TODO-correcoes-prd item 11.
- **Aplicação (2026-04-10):**
  - `SPEC/06-definicoes-complementares.md`: nova seção `## Mecanismo de notificação em tempo real` com transporte, autenticação, envelope, payloads por evento, regras de deduplicação e degradação graceful.
  - `SPEC/03-fila-scoring-estados-sla.md`: tabela de SLA atualizada — "Canal principal" agora nomeia os eventos WebSocket e referencia SPEC/06; "Mecanismo" atualizado para `Event-driven (WebSocket, DEC-017)`.
  - `TODO-correcoes-prd.md`: item 11 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-017; "Próxima disponível" atualizada para DEC-018.

---

## DEC-018 — Remoção da integração RH/Folha; denominador de REQ-MET-002 via sistema

- **Estado:** Decidido
- **Data:** 2026-04-10
- **Contexto:** O item 12 do TODO de correções do PRD requeria definir o contrato de integração com o sistema de RH/Folha da FGR para alimentar o denominador de `REQ-MET-002` (adoção e engajamento operacional). Após revisão de escopo, decidiu-se que essa integração está fora do MVP.
- **Decisão:**
  1. A integração com sistema externo de RH/Folha é removida do escopo do MVP.
  2. O denominador de `REQ-MET-002` (`operadores_cadastrados_quinzena`) passa a ser calculado diretamente a partir dos operadores cadastrados e ativos no sistema FGR-OPS para a obra (`User` com perfil `OPERADOR`, `deletadoEm IS NULL`, criados antes ou no último dia da quinzena).
  3. A subsecção "Fonte do denominador e integração" em SPEC/06 é removida. O artefato de validação renomeia `total_folha` → `total_cadastrados`.
  4. O campo `operadoresNaFolha` no contrato de `GET /relatorios/sla` (SPEC/08) é renomeado para `operadoresCadastrados`.
  5. Integração com RH/Folha poderá ser endereçada numa fase futura como módulo independente do FGR-OPS.
- **Justificativa:** Reduzir acoplamento externo no MVP. O denominador baseado no cadastro interno é suficiente para medir adoção em obras-piloto; refinamento com folha de pagamento pode ser adicionado na Fase 2 sem quebra de contrato.
- **Achados resolvidos:** TODO-correcoes-prd item 12.
- **Aplicação (2026-04-10):**
  - `SPEC/06-definicoes-complementares.md`: denominador atualizado; subsecção "Fonte do denominador e integração" removida; `total_folha` → `total_cadastrados` na tabela do artefato de validação.
  - `SPEC/08-api-contratos.md`: `operadoresNaFolha` → `operadoresCadastrados` em `GET /relatorios/sla`.
  - `PRD/06-metricas-riscos.md`: `REQ-MET-002` — referência à "folha da quinzena" substituída por "operadores cadastrados e ativos no sistema".
  - `TODO-correcoes-prd.md`: item 12 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-018; "Próxima disponível" atualizada para DEC-019.

---

## Fase 2 — Correcoes de achados importantes

As correcoes abaixo nao exigiram decisao de produto nova; derivam directamente dos achados da auditoria e das decisoes ja tomadas na Fase 0.

### Fase 2.1 — SPEC/03-fila-scoring-estados-sla.md (UI nao bloqueante)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M03-002`, `SPEC-M04-004`, `SPEC-M06-002`
- **Correcao:** Passo 3 (Destaque Visual de Prioridade Maxima) expandido para explicitar contrato de experiencia da fila do operador: UI nao bloqueante, demandas restantes visiveis e rolaveis na UI mobile. `REQ-JOR-004` adicionado a linha de rastreio PRD.

### Fase 2.2 — SPEC/00-visao-arquitetura.md (Checkpoint Manual + Rate Limiting)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M01-004`, `SPEC-M05-001`
- **Correcao SPEC-M01-004:** Seccao Arquitetura Tatica (DDD) expandida para explicitar Checkpoint Manual como mecanismo de localizacao declarada sem GPS/IoT, posicao neutra na primeira demanda do turno e relacao com `REQ-OBJ-004`/`REQ-SCO-004`.
- **Correcao SPEC-M05-001:** ADR de Rate Limiting expandida com contrato normativo conforme `REQ-NFR-006`: endpoints exactos (`/auth/login`, `/auth/pin`, `POST /demandas`, `POST /demandas/bulk`), `HTTP 429 Too Many Requests` com `Retry-After`, bloqueio temporario de 15 minutos por IP ou utilizador.

### Fase 2.3 — SPEC/05-backlog-mvp-glossario.md (Backlog, Gatilhos, Governanca)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M01-002`, `SPEC-M01-003`, `SPEC-M07-003`
- **Correcao SPEC-M01-002:** Adicionada seccao "Criterios de promocao para Fase 2" com tabela cobrindo `REQ-SCO-GAT-001..004`. Linha de rastreio PRD actualizada.
- **Correcao SPEC-M01-003:** Adicionado item explicito para `REQ-SCO-F2-005` (migracao de dados legados e roteirizacao geocolocada) na lista de itens adiados.
- **Correcao SPEC-M07-003:** Adicionada seccao "Governanca da taxonomia espacial (`REQ-RISK-001`)" com 4 regras tecnicas: validacao referencial, auditoria cadastral, restricao de exclusao e relatorio de consistencia.

### Fase 2.4 — SPEC/01-modulos-plataforma.md + SPEC/02-modelo-dados.md

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M03-001`, `SPEC-M04-002`, `SPEC-M04-003`, `SPEC-M07-001`
- **Correcao SPEC-M03-001:** Capacidade #1 (Solicitacao) expandida para explicitar captura obrigatoria de localizacao de trabalho (`SetorOperacional`, opcionalmente `Quadra`/`Lote`) no momento da abertura da demanda.
- **Correcao SPEC-M04-002:** Adicionada capacidade #2 (Agrupamento e criacao multipla) com contrato funcional explicito: payload bulk, demandas independentes, `DemandaGrupo` para rastreio.
- **Correcao SPEC-M04-003:** Adicionada especificacao de `tempoExecucaoMs` como campo calculado (`finalizadoEm - iniciadoEm`) persistido na conclusao. Timestamps offline prevalecem.
- **Correcao SPEC-M07-001:** Adicionada seccao "Medicao canonica de tempo operacional (`REQ-MET-001`)" com definicoes de Horas Disponiveis, Horas em Operacao e consulta de referencia.

### Fase 2.5 — SPEC/06-definicoes-complementares.md (Rastreabilidade)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M05-003`
- **Correcao:** Adicionada seccao "Politica de rastreabilidade dos recursos operacionais (`REQ-NFR-004`)" com tabela uniforme de auditabilidade para todas as entidades operacionais, regras transversais de `ResourceAuditLog` e politica de soft-delete.

### Fase 2.6 — Ficheiros PRD (referencias cruzadas)

- **Data:** 2026-03-20
- **Achados resolvidos:** `PRD-M01-001`, `PRD-M01-002`, `PRD-M02-001`, `PRD-M03-001`, `PRD-M04-001`, `PRD-M06-001`, `PRD-M07-002`
- **PRD-M01-001:** Apontadores SPEC adicionados em `REQ-OBJ-003`, `REQ-OBJ-004`, `REQ-SCO-003`, `REQ-SCO-004` de `PRD/00-visao-escopo.md`.
- **PRD-M01-002:** Apontadores SPEC adicionados nas seccoes Fora do Escopo e Criterios de Promocao para `05-backlog-mvp-glossario.md`.
- **PRD-M02-001:** `PRD/01-usuarios-rbac.md` actualizado — `REQ-RBAC-005` e `REQ-RBAC-006` explicitam leitura de contexto auxiliar para Empreiteiro e Operador.
- **PRD-M03-001:** `PRD/02-jornada-usuario.md` — `REQ-JOR-001` agora especifica seleccao de `SetorOperacional` (obrigatorio) e `Quadra`/`Lote` (opcional). *(Nota: subsequentemente actualizado por DEC-005 — Quadra/Lote tornados obrigatorios, Local Externo introduzido, SetorOperacional derivado. Revisto por DEC-006 — entrega formal de material adiada para pos-MVP; movimentacao de massas como demanda regular.)*
- **PRD-M04-001:** `PRD/03-requisitos-funcionais.md` — apontadores SPEC adicionados para `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-005`, `REQ-FUNC-007`, `REQ-FUNC-010`.
- **PRD-M06-001:** `PRD/05-criterios-aceite.md` — `REQ-ACE-007` migrado para seccao "Seguranca de token e gestao de sessao" com 3 cenarios Gherkin (expiracao/renovacao, invalidacao por logout, deteccao de reuso).
- **PRD-M07-002:** `PRD/06-metricas-riscos.md` — `REQ-RISK-001` agora inclui mitigacao explicita com responsavel, validacao, auditoria, restricao de exclusao e relatorio. Apontador SPEC actualizado.

---

## Correções directas (sem decisão de produto pendente)

### Fase 1.3 — Cobertura de `REQ-SCO-003` (`SPEC-M01-001`)

- **Data:** 2026-03-20
- **Tipo:** Lacuna documental — gap de cobertura SPEC sem ambiguidade de produto.
- **Contexto:** O PRD define `REQ-SCO-003` (Gestão de Recursos: Cadastro de Maquinário e Ajudantes) e aponta para `SPEC/02-modelo-dados.md`, que já documenta as entidades. Contudo, o SPEC primário do M01 (`SPEC/00-visao-arquitetura.md`) não referenciava `REQ-SCO-003` nem mencionava os atributos de cadastro, ficando sem cobertura localizável no escopo de auditoria do módulo.
- **Correcção aplicada:**
  - `SPEC/00-visao-arquitetura.md` §Arquitetura Tática (DDD): adicionado `REQ-SCO-003` ao rastreio PRD; texto expandido para documentar cadastro de `Maquinario` (placa, TipoMaquinario, Servico vinculado, propriedade FGR/Terceiro) e `Ajudante` (recurso humano sem credencial própria), com referência cruzada a `02-modelo-dados.md`.
- **Artefactos regenerados:** `M01/consolidated.json`, `M01/traceability.csv`, `M01/traceability-stub.md`.
- **Achado resolvido:** `SPEC-M01-001` (bloqueante → resolvido)

---

## Fase 3 — Correcção de achados menores e revalidação global

### Fase 3.1 — Nomenclatura e justificativa de leitura de contexto (M02)

- **Data:** 2026-03-20
- **Tipo:** Correcção documental — nomenclatura inconsistente e decisão de design sem justificativa.
- **Achados resolvidos:** `PRD-M02-002`, `SPEC-M02-002`, `SPEC-M02-001`
- **Correcções aplicadas:**
  - **PRD-M02-002 (menor):** `PRD/01-usuarios-rbac.md` — adicionada nota de nomenclatura na secção "Princípios de autorização do produto" fixando `Operador de Maquinário` (nome completo na matriz base) e `Operador` (nome curto) como sinónimos oficiais do perfil `REQ-RBAC-006`.
  - **SPEC-M02-002 (menor):** `SPEC/04-rbac-permissoes.md` — adicionada nota de nomenclatura na secção "Perfis de acesso" e anotação `(sinónimo: Operador de Maquinário)` no item 6 da lista de perfis, alinhando terminologia com o PRD.
  - **SPEC-M02-001 (importante):** `SPEC/04-rbac-permissoes.md` — adicionada decisão de design na secção "Decisões de design" justificando a permissão de leitura (`read`) em recursos de contexto para `Empreiteiro` e `Operador`: estritamente funcional, aderente a `REQ-RBAC-005` e `REQ-RBAC-006`, limitada ao tenant da obra atribuída, sem bypass cross-tenant nem capacidade de mutação ou exportação.
- **Artefactos regenerados:** `M02/consolidated.json`, `M02/traceability.csv`, `M02/traceability-stub.md`.

### Fase 3.2 — Revalidação global

- **Data:** 2026-03-20
- **Resultado:** Todos os 37 achados resolvidos (7 bloqueantes, 28 importantes, 2 menores). Cobertura: 62 requisitos cobertos, 2 parciais (M01), 0 não cobertos. Risco geral: baixo.
- **Artefactos regenerados:** `consolidated-global.json`, `traceability.md`.
