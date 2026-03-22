# Módulos da plataforma

**Rastreio PRD:** `REQ-JOR-001`, `REQ-JOR-004`, `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-005`, `REQ-FUNC-010`

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
3. **Gestão da fila**: distribuição transparente filtrada por setores, jurisdição logística e score.
4. **Execução**: fluxo de campo para assumir, concluir, devolver ou contestar tarefas via máquina de estados.
5. **Expediente**: controle de início e fim da jornada operacional do maquinário, com máquina e ajudante ativos.
6. **Operações dinâmicas**: alocação manual, empilhamento não destrutivo e trilha de auditoria obrigatória.

## Dependências sobre o Core

- O `Machinery Link` depende do `Core` para conhecer `Obra`, `User`, `Role` e o recorte tenant-scoped.
- O filtro logístico usa entidades espaciais mantidas no `Core`, como `SetorOperacional`, `Quadra`, `Lote`, `Rua` e relações de adjacência.
- O catálogo de `Tipos de Maquinario`, `Maquinarios`, `Servicos` e autorizações do `Operador` determina elegibilidade de atendimento.
- O `RegistroExpediente` combina referências do `Core` com o estado operacional corrente para definir contexto de execução.

## Critérios de aceite suportados

- [REQ-ACE-004](../PRD/05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](../PRD/05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](../PRD/05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
