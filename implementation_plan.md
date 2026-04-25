# Prototipação das Telas Faltantes (MVP)

Com base na análise da documentação (em especial `UI-DESIGN.md`, `07-design-ui-logica.md` e `01-modulos-plataforma.md`), identifiquei as telas necessárias para fechar o escopo MVP. As telas seguirão o padrão estabelecido (layouts ASCII, fluxo, rbac e mapping).

## Open Questions

> [!NOTE]
> Os CRUDs de configuração (Setores, Catálogos, Usuários) fazem parte do escopo técnico MVP necessário para o *bootstrapping* da obra. Eu agrupei os CRUDs por domínio para evitar excesso de arquivos pequenos, criando uma visão de "Configurações da Obra". O plano atende a sua necessidade organizacional?

## Proposed Changes

### Módulo Machinery-Link
Telas referentes à operação do sistema pós-configuração.

#### [NEW] [04-auditoria-operacao.md](file:///c:/dev/FGR-Ops-docs/docs/UI/Machinery-Link/04-auditoria-operacao.md)
Tela listada na sidebar para `AdminOperacional` e `Board`. Histórico de demandas, log de trilha de auditoria (`REQ-ACE-004`) e encerramentos.

#### [NEW] [05-gestao-agendamentos.md](file:///c:/dev/FGR-Ops-docs/docs/UI/Machinery-Link/05-gestao-agendamentos.md)
Tela dedicada de Agendamentos (DEC-026, DEC-027, DEC-029). Aprovação da fila, acompanhamento de expirações e gerenciamento de cancelamentos antecipados.

#### [NEW] [06-gestao-operadores.md](file:///c:/dev/FGR-Ops-docs/docs/UI/Machinery-Link/06-gestao-operadores.md)
View de monitoramento de operadores (listada na sidebar do Dashboard), gestão de inatividade (`REQ-FUNC-013`), badges e visualização de quem está no campo.

---

### Módulo FGR-Ops
Telas do painel de administração da Plataforma e *Bootstrapping* do módulo (Configurações / CRUDs).

#### [NEW] [03-crud-obras.md](file:///c:/dev/FGR-Ops-docs/docs/UI/FGR-Ops/03-crud-obras.md)
Acesso `SuperAdmin`. Tela para cadastrar a Obra e realizar o toggle de ativação do Machinery Link.

#### [NEW] [04-configuracoes-obra.md](file:///c:/dev/FGR-Ops-docs/docs/UI/FGR-Ops/04-configuracoes-obra.md)
Onde o `AdminOperacional` fará o setup da Obra: 
1. Malha Espacial (Setores, Quadras, Lotes, Adjacências).
2. Catálogos (Tipos de Máquina, Máquinas, Serviços e Materiais).
3. Parâmetros (Expediente e Pesos da Fila).

#### [NEW] [05-gestao-acessos.md](file:///c:/dev/FGR-Ops-docs/docs/UI/FGR-Ops/05-gestao-acessos.md)
Onde são gerenciadas as Empreiteiras, Empreiteiros e Operadores (atribuição de PIN e tipos de máquina operáveis).

## Verification Plan
Após aprovação, criarei os arquivos com as exatas demarcações de layout (ASCII), comportamento e Rastreio PRD exigidas pelo Claude Design para geração do protótipo final. Ao finalizá-los, utilizarei o `traceability-check.md` para garantir o vínculo bidirecional correto e o `audit` para certificar consistência.
