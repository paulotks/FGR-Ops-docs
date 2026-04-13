# Backlog MVP e glossário

**Rastreio PRD:** `REQ-SCO-F2-001`, `REQ-SCO-F2-002`, `REQ-SCO-F2-003`, `REQ-SCO-F2-004`, `REQ-SCO-F2-005`, `REQ-SCO-F2-006`, `REQ-SCO-GAT-001`, `REQ-SCO-GAT-002`, `REQ-SCO-GAT-003`, `REQ-SCO-GAT-004`, `REQ-RISK-001`

Este módulo consolida o backlog técnico fora do escopo imediato do MVP e o glossário base usado ao longo da documentação modular.

## Backlog MVP

### Escopo delimitado

O MVP contempla exclusivamente o módulo `Machinery Link`. Capacidades como `Almoxarifado`, rastreamento `IoT`, aplicações nativas (`App Store` e `Google Play`) e a entidade `ServicoDinamico` ficam formalmente adiadas para uma Fase 2, preservando o foco no go-live operacional.

### Itens adiados para Fase 2 {#itens-adiados-para-fase-2}

- **Telemetria e IoT**: dependem de hardware homologado e maturidade adicional na observabilidade de campo.
- **Módulo de Almoxarifado**: permanece fora do MVP para evitar alargar o domínio operacional nesta entrega.
- **Aplicações nativas**: o MVP permanece em `PWA`; mobile nativo fica condicionado a necessidades técnicas futuras.
- **Migração de dados legados e roteirização geolocalizada** (`REQ-SCO-F2-005`): a importação de histórico operacional de sistemas anteriores e a roteirização em mapas geolocalizados ficam fora do MVP. A migração depende de mapeamento de esquemas legados por obra e validação de integridade com o modelo canônico do FGR-OPS; a roteirização depende de integração com serviço de mapas e maturidade da malha espacial em produção.
- **ServicoDinamico**: adiado por falta de regras maduras para exclusão mútua, sincronismo e dependências múltiplas entre frentes.
- **Entrega formal de material** (`PontoOrigem`): fluxo estruturado de entrega de material a partir de origens externas fixas (centrais de concreto, usinas, etc.) com pré-preenchimento automático de origem e logística de entrega. Permanece adiado (DEC-006). *Nota: a flag `exigeTransporte` foi reintroduzida no MVP em DEC-009 com escopo restrito a transporte interno da obra (destino obrigatório, sem `PontoOrigem`); apenas o fluxo de origem externa permanece neste backlog.*

### Critérios de promoção para Fase 2 {#criterios-de-promocao-para-fase-2}

A transição de itens adiados para desenvolvimento ativo ocorre mediante gatilhos explícitos, alinhados com os critérios definidos no PRD.

| ID | Item | Gatilho de promoção |
| :--- | :--- | :--- |
| `REQ-SCO-GAT-001` | Telemetria e IoT | Estabilização de 95% na acurácia do Checkpoint Manual por 3 meses consecutivos **E** viabilização de contrato de hardware homologado pela FGR. |
| `REQ-SCO-GAT-002` | Módulo de Almoxarifado | Consolidação da taxonomia de Materiais no Machinery Link atingindo 500+ registros únicos ativos em ambiente produtivo. |
| `REQ-SCO-GAT-003` | Aplicativos Nativos | Necessidade técnica comprovada de acesso a APIs de hardware (Bluetooth/NFC) ou requisito de segurança da informação que inviabilize o PWA. |
| `REQ-SCO-GAT-004` | Serviços Dinâmicos | Registro de 20%+ de demandas devolvidas por erro de exclusão mútua ("deadlocks operacionais") onde o agrupamento passivo via `DemandaGrupo` se prove insuficiente. |

> Nota: a avaliação dos gatilhos é responsabilidade conjunta de Produto e Operações, com revisão trimestral documentada.

### Governança da taxonomia espacial (`REQ-RISK-001`) {#governanca-da-taxonomia-espacial-req-risk-001}

O motor de fila depende da coerência cadastral de `SetorOperacional`, `Quadra`, `Lote`, `Rua` e respectivas adjacências. Para mitigar o risco de degradação da atribuição automática por inconsistências cadastrais, o MVP deve implementar as seguintes regras técnicas de governança:

1. **Validação na criação/edição**: ao criar ou alterar entidades espaciais, o sistema valida integridade referencial (ex.: `Lote` pertence a `Quadra` existente na mesma obra, adjacências não referenciam entidades de obras distintas).
2. **Auditoria cadastral**: toda criação, edição ou exclusão lógica de entidades espaciais gera entrada em `DemandaLog` (ou log dedicado) com `userId`, `timestamp`, valores antigos/novos e `obraId`.
3. **Restrição de exclusão**: entidades espaciais referenciadas por demandas ativas (`PENDENTE`, `EM_ANDAMENTO`, `AGENDADA`) não podem ser excluídas logicamente até a conclusão ou cancelamento das demandas vinculadas.
4. **Relatório de consistência**: o painel administrativo deve disponibilizar relatório consultivo que identifique `Lotes` sem adjacência definida, `Quadras` vazias e `SetoresOperacionais` sem operador vinculado, acessível a `AdminOperacional` e `SuperAdmin`.

## Glossário técnico

- **Machinery Link**: módulo MVP dedicado ao fluxo requisição-execução das máquinas.
- **Setor Operacional (Jurisdição Logística)**: filtro primário geográfico ou contextual que ancora operadores e máquinas a limites restritos, suprimindo demandas fora do seu contexto de trabalho.
- **Checkpoint Manual**: cálculo de proximidade sem IoT/GPS que infere a localização atual da máquina. No início do expediente, a localização é neutra (`Fora da Obra`) e o checkpoint só passa a influenciar a adjacência após a primeira conclusão do turno.
- **Arquitetura Tática (DDD)**: separação entre regras puras do domínio operacional e a infraestrutura tecnológica, como `NestJS`, `SQL Server` e `Prisma`.
- **DemandaLog**: trilha auditável que registra transições, justificativas e eventos relevantes da `Demanda`.
- **AGENDADA**: estado inicial de uma demanda programada para o futuro, invisível ao operador até a janela de ativação.
- **dataAgendada**: atributo temporal que define o momento exato do atendimento solicitado e governa a transição para `PENDENTE` 60 minutos antes do horário-alvo.
- **AuditLogCrossTenant**: log especializado para registrar acessos privilegiados de `SuperAdmin` e `Board` que transcendem o isolamento por obra.
- **TurnoAjudante**: registro cronológico associado ao `RegistroExpediente` que mapeia a relação temporal entre ajudante e par operador-máquina.
- **recalcular_fila**: ação administrativa que força a atualização imediata de scores pendentes numa obra com base nos pesos atuais.
- **Perfilar** (`Iniciar Depois / Perfilar`): ação disponível no pop-up de notificação de nova demanda (`REQ-FUNC-013`). Quando o operador escolhe "Iniciar Depois (Perfilar)", a demanda permanece em `PENDENTE`, o pop-up é fechado e o operador retorna à tela de fila sem iniciar execução. Não há transição de estado — a demanda aguarda na fila pela ordem de score até o operador decidir iniciá-la.
- ~~**SolicitacaoCancelamento**~~: entidade removida do MVP (DEC-019). O cancelamento de demandas em `EM_ANDAMENTO` pelo `Operador` passou a ser direto, com justificativa obrigatória registrada em `DemandaLog`, sem estado intermediário de aprovação gerencial.
