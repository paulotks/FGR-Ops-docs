# Utilizadores e RBAC

Esta secção consolida os perfis do produto, o respetivo escopo de atuação e as permissões-base esperadas no MVP.

## Matriz base de perfis

| ID | Perfil | Escopo | Permissões-base | SPEC |
|----|--------|--------|-----------------|------|
| `REQ-RBAC-001` | `SuperAdmin` | `cross-tenant` | Visão transversal de toda a plataforma e gestão global de acesso. | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md#perfis-de-acesso) |
| `REQ-RBAC-002` | `Board` | `cross-tenant` | Acesso analítico e executivo a dashboards e comparativos entre obras, limitado a leitura. | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass) |
| `REQ-RBAC-003` | `AdminOperacional` | Obra(s) explicitamente atribuída(s) | Gestão operacional da obra, incluindo criação de demandas atípicas, alocação manual de operador e administração de cadastros operacionais. | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md#matriz-completa-de-permissoes-por-recurso-lacuna-1) |
| `REQ-RBAC-004` | `UsuarioInternoFGR` | Obra atribuída | Visibilidade gerencial, gestão de contestações na máquina de estados e seleção manual de operadores na criação de demandas. | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md#matriz-de-permissoes-condicionadas-ao-estado-da-demanda-lacuna-2) |
| `REQ-RBAC-005` | `Empreiteiro` | Contexto do próprio trabalho na obra atribuída | Abertura de chamados e visibilidade restrita às suas demandas, sem acesso às filas de outros empreiteiros. Leitura de contexto auxiliar (obra, hierarquia territorial, catálogo de serviços e materiais) é permitida na medida necessária para preencher o formulário de abertura de demanda. | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md#matriz-completa-de-permissoes-por-recurso-lacuna-1) |
| `REQ-RBAC-006` | `Operador de Maquinário` | Contexto do próprio expediente e fila operacional | Acesso exclusivamente às demandas otimizadas/direcionadas na interface mobile, com prioridades máximas em destaque no topo. Leitura de contexto auxiliar (obra, setor operacional, quadra, lote, catálogo de maquinário e serviços) é permitida na medida necessária para visualizar a fila e executar demandas. | [04-rbac-permissoes.md](../SPEC/04-rbac-permissoes.md#matriz-de-permissoes-condicionadas-ao-estado-da-demanda-lacuna-2) |

## Princípios de autorização do produto

- A plataforma adota uma matriz rígida de perfis e permissões; capacidades administrativas e operacionais não são inferidas fora das regras explícitas do papel atribuído.
- O escopo por obra é a regra padrão. Apenas perfis `cross-tenant` podem operar fora do isolamento por obra.
- O perfil `Board` existe para leitura analítica e comparativa, não para execução operacional nem mutações de dados.
- O perfil `AdminOperacional` pode gerir uma ou várias obras, mas sempre por atribuição explícita.
- O perfil `Operador` utiliza uma experiência mobile focada na execução, e não um painel geral de administração.

## Critérios de aceite relacionados

- [REQ-ACE-001](05-criterios-aceite.md#isolamento-rbac-e-multi-tenancy)
- [REQ-ACE-008](05-criterios-aceite.md#isolamento-cross-tenant-auditado)
