# Visão e escopo

Documento migrado a partir de `PRD-FGR-OPS.md` (seções 1–3). Rastreio técnico: [SPEC — visão e arquitetura](../SPEC/00-visao-arquitetura.md).

## 1. Contexto

**REQ-CTX-001** **Problema:** A FGR Incorporações opera múltiplas obras de forma simultânea (atualmente 4 a 5), mas o gerenciamento de demandas operacionais, especialmente o fluxo de maquinários pesados, é feito através de sistemas isolados, manuais ou fragmentados por obra.

**REQ-CTX-002** **Quem enfrenta:** Gestores de obra e administradores lidam com falta de padronização, inconsistência de nomenclatura e ausência de consolidação gerencial. Empreiteiros enfrentam burocracia para solicitar máquinas, e operadores em campo carecem de direcionamento otimizado.

**REQ-CTX-003** **Relevância:** Sem uma fundação tecnológica centralizada, a operação escala com ineficiência. A padronização imediata é essencial para viabilizar um ecossistema digital que futuramente suportará novos módulos (como almoxarifado e rastreamento avançado).

---

## 2. Objetivos

**REQ-OBJ-001** Centralizar a gestão operacional das obras em uma única plataforma (FGR-OPS).  
→ SPEC: [../SPEC/00-visao-arquitetura.md#visao-macro](../SPEC/00-visao-arquitetura.md#visao-macro)

**REQ-OBJ-002** Garantir isolamento de dados rigoroso por obra de forma automatizada (Multi-tenancy).  
→ SPEC: [../SPEC/00-visao-arquitetura.md#principios-arquiteturais](../SPEC/00-visao-arquitetura.md#principios-arquiteturais), [../SPEC/04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md)

**REQ-OBJ-003** Digitalizar e otimizar 100% o fluxo de requisição, despacho e execução de maquinários (módulo Machinery Link).  
→ SPEC: [../SPEC/01-modulos-plataforma.md](../SPEC/01-modulos-plataforma.md), [../SPEC/00-visao-arquitetura.md#visao-geral](../SPEC/00-visao-arquitetura.md#visao-geral)

**REQ-OBJ-004** Aumentar a eficiência da frota reduzindo deslocamentos ociosos através de um algoritmo de fila inteligente, fundamentado em jurisdição logística e localização declarada (sem dependência de GPS).  
→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md), [../SPEC/00-visao-arquitetura.md#arquitetura-tatica-ddd](../SPEC/00-visao-arquitetura.md#arquitetura-tatica-ddd)

**REQ-OBJ-005** Prover uma ferramenta nativamente desenhada para o uso fluido de operadores em campo via smartphone.

---

## 3. Escopo

### Dentro do Escopo (MVP Restrito ao Machinery Link)

O produto viável mínimo concentra-se estritamente no fluxo operacional de máquinas, garantindo alinhamento rápido:

**REQ-SCO-001** **Fundação Core:** Autenticação JWT, gestão de usuários (incluindo vínculo de habilitação por Tipo de Maquinário), perfis de acesso padronizados, cadastro corporativo e sistema de governança multi-tenancy.  
→ SPEC: [../SPEC/00-visao-arquitetura.md#decisoes-arquiteturais-adrs](../SPEC/00-visao-arquitetura.md#decisoes-arquiteturais-adrs), [../SPEC/01-modulos-plataforma.md](../SPEC/01-modulos-plataforma.md)

**REQ-SCO-002** **Módulo Machinery Link:** Ciclo de vida completo da Demanda (PENDENTE -> EM_ANDAMENTO -> CONCLUIDA), manutenção de catálogos (serviços e materiais), agrupamento de demandas e controle da organização espacial (Quadra, Lote, Rua, Adjacências).  
→ SPEC: [../SPEC/01-modulos-plataforma.md](../SPEC/01-modulos-plataforma.md), [../SPEC/02-modelo-dados.md](../SPEC/02-modelo-dados.md)

**REQ-SCO-003** **Gestão de Recursos:** Cadastro de Maquinário (Placa, Tipo, Serviços e Propriedade) e Cadastro de Ajudantes (sem acesso ao sistema).  
→ SPEC: [../SPEC/02-modelo-dados.md](../SPEC/02-modelo-dados.md), [../SPEC/00-visao-arquitetura.md#arquitetura-tatica-ddd](../SPEC/00-visao-arquitetura.md#arquitetura-tatica-ddd)

**REQ-SCO-004** **Fila Operacional Inteligente:** Algoritmo dinâmico governado primariamente pelo **Setor Operacional (Jurisdição Logística)** e priorizado com base em proximidade espacial (Checkpoint Manual), habilitação do operador e urgência.  
→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md), [../SPEC/00-visao-arquitetura.md#arquitetura-tatica-ddd](../SPEC/00-visao-arquitetura.md#arquitetura-tatica-ddd)

**REQ-SCO-005** **Interface Operacional (Mobile):** Progressive Web App (PWA) responsivo para operadores realizarem check-in (seleção de máquina e ajudante) e executarem demandas.  
→ SPEC: [../SPEC/00-visao-arquitetura.md#principios-arquiteturais](../SPEC/00-visao-arquitetura.md#principios-arquiteturais)

### Fora do Escopo (Fase 2+)

→ SPEC: [../SPEC/05-backlog-mvp-glossario.md](../SPEC/05-backlog-mvp-glossario.md)

**REQ-SCO-F2-001** **Telemetria Básica**: Campos de Horímetro, KM e similares no cadastro de máquinas.

**REQ-SCO-F2-002** **Módulo de Almoxarifado**: Requisição de materiais de estoque ou ferramentas diversas.

**REQ-SCO-F2-003** **Rastreamento de Ativos (IoT)**: Integração com hardwares de telemetria e posicionamento global (GPS automático).

**REQ-SCO-F2-004** **Aplicativos Nativos**: Disponibilização em lojas (`App Store`/`Google Play`).

**REQ-SCO-F2-005** Migração de dados legados e roteirização em mapas geocodificados.

**REQ-SCO-F2-006** **Serviços Dinâmicos Automáticos (Fase 2)**: Algoritmos de resolução automática de deadlocks transacionais ou co-dependência entre múltiplas frentes de serviço sem intervenção humana. O MVP utiliza apenas agrupamentos passivos via `DemandaGrupo`.

#### Critérios de Promoção para Fase 2

→ SPEC: [../SPEC/05-backlog-mvp-glossario.md#criterios-de-promocao-para-fase-2](../SPEC/05-backlog-mvp-glossario.md#criterios-de-promocao-para-fase-2)

A transição de itens do "Fora de Escopo" para o desenvolvimento ativo (Fase 2) ocorrerá mediante o atendimento dos seguintes gatilhos:

**REQ-SCO-GAT-001** **Telemetria e IoT**: Estabilização de 95% na acurácia do Checkpoint Manual por 3 meses consecutivos E viabilização de contrato de hardware homologado pela FGR.

**REQ-SCO-GAT-002** **Módulo de Almoxarifado**: Consolidação da taxonomia de Materiais no Machinery Link atingindo 500+ registros únicos ativos em ambiente produtivo.

**REQ-SCO-GAT-003** **Aplicativos Nativos**: Necessidade técnica comprovada de acesso a APIs de hardware (Bluetooth/NFC) ou requisito de segurança da informação que inviabilize o PWA.

**REQ-SCO-GAT-004** **Serviços Dinâmicos**: Registro de 20%+ de demandas devolvidas por erro de exclusão mútua ("deadlocks operacionais") onde o agrupamento passivo via `DemandaGrupo` se prove insuficiente.

---
