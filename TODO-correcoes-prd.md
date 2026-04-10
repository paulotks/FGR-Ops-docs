# TODO — Correções PRD/SPEC pré-desenvolvimento

> Gerado em: 2026-04-09
> Baseado na revisão de prontidão do PRD para início de desenvolvimento.
> Sequência: simples e rápidos primeiro → críticos e estruturais depois.

---

## FASE 1 — Correções rápidas (1–2 horas cada, sem impacto estrutural)

### [x] 1. Corrigir nomes de estados em SPEC/07

**Arquivo:** `docs/SPEC/07-design-ui-logica.md`
**O que fazer:** Substituir os nomes de estados e ações inconsistentes pelos nomes canônicos do SPEC/03.

| Trocar                       | Por                           |
| ---------------------------- | ----------------------------- |
| `EM_EXECUCAO`                | `EM_ANDAMENTO`                |
| `PENDENTE_OPERADOR`          | `PENDENTE`                    |
| `PAUSADA`                    | Remover ou anotar como Fase 2 |
| Botão "Pausar"               | Remover ou anotar como Fase 2 |
| Botão "Iniciar Deslocamento" | Remover ou anotar como Fase 2 |

Decisão: manter `PAUSADA` no MVP, abrir REQ-FUNC-011 e adicionar as transições correspondentes em SPEC/03 antes de seguir.

---

### [x] 1b. Adicionar transições de PAUSADA em SPEC/03 e registrar DEC-011
  Arquivo: docs/SPEC/03-fila-scoring-estados-sla.md + docs/audit/decisions-log.md
  Pré-requisito para: Itens 7 e 8

### [x] 2. Documentar o papel da entidade `Rua` no domínio

**Arquivo:** `docs/SPEC/02-modelo-dados.md`
**O que fazer:** Adicionar ao ER e ao texto a relação de `Rua` com as demais entidades espaciais. Responder:
- `Rua` é filha de `Quadra`? Ou está no mesmo nível?
- `Rua` participa do cálculo de adjacência?
- Ou é apenas dado descritivo sem impacto no motor de fila?

Se for apenas descritiva, registrar isso como DEC-011 e remover das permissões RBAC ou adicionar nota explicativa.
Resposta: A rua é formada por lotes e quadras, ou seja, é filha de quadra. Exemplo. o posto da Quadra X e da quadra Y estão na rua Z.
Vamos revisar melhor o papel da RUA no algoritmo de adjacência e prioridades. Pois a RUA será necessária para que o usuário visualize onde cada maquina está de formma mais fácil, a fim de evitar colisão entre maquinarios.

---

### [x] 3. Especificar o fluxo de cancelamento do Empreiteiro na UI

**Arquivo:** `docs/SPEC/07-design-ui-logica.md` (seção 1.1 — Mobile do Empreiteiro)
**O que fazer:** Adicionar ao fluxo do empreiteiro a tela/ação de cancelar demanda própria em `PENDENTE`. O RBAC já autoriza (`machinery:demanda:cancel` com condição [4]), mas a UI não documenta como isso se manifesta na interface

Decisão: botão no card da demanda + modal com justificativa?. Replicar essa decisão em todos os arquivos necessários

---

### [x] 4. Documentar a sequência de setup inicial de uma obra

**Arquivo:** `docs/SPEC/01-modulos-plataforma.md` (nova seção) ou `docs/SPEC/06-definicoes-complementares.md`
**O que fazer:** Adicionar seção "Bootstrapping de obra" descrevendo a sequência mínima de cadastros para uma obra ir ao ar:

1. Criar `Obra`
2. Criar `SetorOperacional` (vinculado à obra)
3. Criar `Quadra` (vinculada à obra + setor)
4. Criar `Lote` (vinculado à quadra)
5. Criar `LoteAdjacencia` (mapear contiguidades)
6. Criar `LocalExterno` (Portaria, Pulmão etc., vinculados ao setor)
7. Criar `TipoMaquinario` (catálogo global)
8. Criar `Servico` (vinculado ao tipo)
9. Criar `Maquinario` (vinculado ao tipo e à obra)
10. Cadastrar `Operador` e vincular aos `TipoMaquinario` autorizados
11. Configurar `expedienteInicio`/`expedienteFim` da obra
12. Configurar pesos da fila (`W_adj`, `W_srv`, `W_mat`) se diferentes do padrão

Resposta + Contexto: FGR Ops é a plataforma que vai receber o Modulo Machinery-Link, que hoje é um sistema standalone e no qual vamos implementar nesse MVP.
Precisamos separar de forma concisa o que é do FGR Ops e o que é do Machinery-Link.
As obras precisam ser cadastradas no FGR Ops e depois importadas para o Machinery-Link. Dentro do machinery-link realizamos as configurações necessárias para o funcionamento do módulo.

Fluxo FGR Ops, Perfil de administrador, Usuário: Gerente de Obra ou Administrador do sistema.
Login no FGR Ops, Seleciona a obra, vai para a tela onde ele visualiza todos os modulos habilitados para essa obra, para o MVP, teremos apenas o Machinery-Link.
Revisar os fluxos e especificar as telas e requisitos específicos do FGR Ops.
a Authenticacao dos Perfis que não são Operadores/Empreiteiros, ou seja, Admin, Gerente de Obra, etc. eles não precisam acessar o FGR Ops, eles precisam acessar apenas o app do Machinery-Link
Teremos um Perfil de Adminstrador do Sistema FGR Ops, que será o responsável por cadastrar as obras e os usuários.
Dentro do machinery-link teremos os perfis especificos do modulo, admin de machinery-link, gerente de obra, operador de sistema, operador de maquinaria, empreiteiro.

O perfil de Diretor, Gerente de Obra, ele será do Nivel FGR Ops, onde ele podera acessar qualquer obra e visualizar os modulos de qualquer obra. Futuramente, iremos desenvolver um modulo no FGR ops, especifico para esse perfil,
para ele cruzar dados entre obras, por exemplo, cruzar dados entre obras que estão em andamento e verificar a quantidade de uso de determinado maquinario, ou quantidade de horas trabalhadas por determinado operador, etc.

---

## FASE 2 — Gaps estruturais (requerem decisão e novo conteúdo documental)

### [ ] 5. Adicionar `setorOperacionalId` à entidade `Quadra` no ER

**Arquivo:** `docs/SPEC/02-modelo-dados.md`
**O que fazer:** A demanda deriva `setorOperacionalId` automaticamente a partir de `quadraId` (mencionado em SPEC/08), mas o ER não mostra essa FK em `Quadra`. Adicionar:

- Campo `setorOperacionalId` na entidade `Quadra` do diagrama Mermaid.
- Relação `SetorOperacional ||--o{ Quadra : "jurisdição"` no ER.
- Regra de integridade: ao criar ou mover uma `Quadra`, o `setorOperacionalId` é obrigatório.
- Registrar como DEC-011 (ou DEC-012 se DEC-011 for usado pela Rua).

Decisão: Antes de qualquer alteração, revisar a regra de SetorOperacional e verificar se não está conflitando com a Rua

---

### [ ] 6. Especificar o vínculo `Empreiteiro` ↔ `Empreiteira`

**Arquivo:** `docs/SPEC/02-modelo-dados.md` e `docs/SPEC/08-api-contratos.md`
**O que fazer:** Definir como um usuário com perfil `Empreiteiro` fica associado a uma entidade `Empreiteira`:
- O `empreiteiraId` é atributo do `User` ou do perfil `Empreiteiro`?
- O vínculo é feito na criação do usuário pelo `AdminOperacional`?
- Adicionar o campo ao ER se necessário.
- Adicionar o campo `empreiteiraId` ao payload de criação de usuário em SPEC/08.

Decisão: Precisamos criar CRUD para Empreiteira, e o Empreiteiro será um usuário do sistema com perfil Empreiteiro, vinculado a Empreiteira cadastrada. Pois a empreiteira pode ter varios empreiteiros,
ou ter apenas um empreiteiro. Para cadastro de empreiteira, será feito pelo Admin Operacional ou perfil qualquer outro perfil de admin. Dados basicos para o MVP, vamos validar a necessidade de adicionar mais campos depois.
Campos: Nome empreiteira, CNPJ (Não obrigatorio no momento), Telefone (Não obrigatorio no momento), Email (Não obrigatorio no momento), Responsavel (Não obrigatorio no momento), Endereço (Não obrigatorio no momento).
Empreiteira deverá ter ID Unico (preparar ambiente para CNPJ também ser uniqKey), e o Empreiteiro será um usuário do sistema com perfil Empreiteiro, vinculado a Empreiteira cadastrada.
No cadastro de Maquinario, teremos o campo para vincular o maquinario a Empreiteira, ou a FGR (FGR é a construtora, ou seja, maquinario proprietário). Sem esquecer do campo que vincula o maquinario a um Operador também.

---

### [ ] 7. Adicionar endpoints de CRUD para recursos operacionais ausentes em SPEC/08

**Arquivo:** `docs/SPEC/08-api-contratos.md`
**O que fazer:** Adicionar seções de contrato para os recursos que têm permissões RBAC definidas mas sem endpoints documentados:

- `LocalExterno`: `GET`, `POST`, `PATCH`, `DELETE` em `/obras/:id/locais-externos`
- `LoteAdjacencia`: `GET`, `POST`, `DELETE` em `/obras/:id/quadras/:quadraId/lotes/:loteId/adjacencias`
- `Ajudante`: `GET`, `POST`, `PATCH`, `DELETE` em `/obras/:id/ajudantes`
- `Material`: `GET`, `POST`, `PATCH`, `DELETE` em `/obras/:id/materiais` (ou catálogo global)
- `SetorOperacional`: `POST`, `PATCH`, `DELETE` em `/obras/:id/setores` (leitura já existe)
- `Quadra`, `Lote`: `POST`, `PATCH`, `DELETE` (leitura parcialmente coberta, mutação não tem contrato)
- Troca de ajudante durante expediente: `POST /operadores/:id/ajudante`

---

### [ ] 8. Adicionar endpoint de checkout de expediente em SPEC/08

**Arquivo:** `docs/SPEC/08-api-contratos.md`
**O que fazer:** Adicionar contrato para encerramento do expediente:

```
POST /operadores/:id/checkout
Perfil: Operador
Request: { "ajudanteId": "uuid | null" }  // opcional, para registro final
Response 200: { "expedienteId": "uuid", "fimEm": "ISO8601", "totalDemandas": number }
Erros: 404 sem expediente ativo | 409 demanda EM_ANDAMENTO pendente de conclusão
```

---

### [ ] 9. Adicionar endpoints de configuração por obra em SPEC/08

**Arquivo:** `docs/SPEC/08-api-contratos.md`
**O que fazer:** Adicionar contratos para configurações da obra que a SPEC menciona como editáveis mas não têm endpoint:

- `PATCH /obras/:id/configuracoes` — pesos da fila (`W_adj`, `W_srv`, `W_mat`) e horário de expediente (`expedienteInicio`, `expedienteFim`)
- `POST /obras/:id/fila/recalcular` — forçar recálculo dos scores pendentes (mencionado em SPEC/03)

---

### [ ] 10. Adicionar endpoint de fila global para AdminOperacional em SPEC/08

**Arquivo:** `docs/SPEC/08-api-contratos.md`
**O que fazer:** SPEC/07 descreve um "Kanban em tempo real" com todas as demandas da obra para o supervisor, mas não há endpoint correspondente em SPEC/08. Adicionar:

```
GET /obras/:id/fila
Perfis: AdminOperacional, UsuarioInternoFGR, SuperAdmin
Query params: ?status=&setorId=&operadorId=&prioridade=&page=&limit=
Response 200: lista paginada de demandas com score, operador, SLA status e posição na fila
```

---

## FASE 3 — Gaps de integração e infraestrutura (podem ser abertos como OpsX separados)

### [ ] 11. Especificar o mecanismo técnico de notificação SLA

**Arquivo:** `docs/SPEC/06-definicoes-complementares.md` (nova seção) ou `docs/SPEC/03-fila-scoring-estados-sla.md`
**O que fazer:** SPEC/03 menciona "UI push de alta prioridade" e "UI push normal" sem definir o canal técnico. Definir:
- Tecnologia de push (WebPush API do browser? SSE? WebSocket já mencionado para `INVALIDATE_QUEUE`?)
- Payload mínimo do evento de SLA (demandaId, prioridade, slaVencimentoEm, operadorId)
- Regra de deduplicação: alerta disparado uma única vez no vencimento (já documentado — confirmar canal)
- Escalação para SuperAdmin: via mesmo canal ou canal separado (ex.: email)?

---

### [ ] 12. Adicionar contrato de integração RH/Folha em SPEC/08

**Arquivo:** `docs/SPEC/08-api-contratos.md`
**O que fazer:** A SPEC/06 define fórmula e regras de elegibilidade para REQ-MET-002 mas o contrato de como os dados chegam ao sistema não está em SPEC/08. Adicionar:
- Se for endpoint REST: `POST /integracoes/folha` com payload definido em SPEC/06 (identificador_folha, User.id, obraId, data_admissao, data_desligamento, status_folha)
- Se for batch CSV/JSON: definir formato, frequência mínima e endpoint de upload
- Endpoint de consulta do último artefato gerado: `GET /obras/:id/metricas/adocao?quinzena=2026-03-01`

---

## Rastreio de progresso

| #   | Item                                       | Criticidade | Status |
| --- | ------------------------------------------ | ----------- | ------ |
| 1   | Corrigir nomes de estados em SPEC/07       | CRÍTICO     | [x]    |
| 1b  | Transições de `PAUSADA` em SPEC/03 + DEC-011 | CRÍTICO  | [x]    |
| 2   | Documentar papel da entidade `Rua`         | MENOR       | [x]    |
| 3   | Fluxo de cancelamento do Empreiteiro na UI | MENOR       | [x]    |
| 4   | Sequência de setup inicial de obra         | IMPORTANTE  | [x]    |
| 5   | FK `setorOperacionalId` em `Quadra` no ER  | CRÍTICO     | [ ]    |
| 6   | Vínculo `Empreiteiro` ↔ `Empreiteira`      | CRÍTICO     | [ ]    |
| 7   | Endpoints CRUD ausentes em SPEC/08         | CRÍTICO     | [ ]    |
| 8   | Endpoint de checkout de expediente         | CRÍTICO     | [ ]    |
| 9   | Endpoints de configuração por obra         | IMPORTANTE  | [ ]    |
| 10  | Endpoint de fila global para admin         | IMPORTANTE  | [ ]    |
| 11  | Mecanismo técnico de notificação SLA       | IMPORTANTE  | [ ]    |
| 12  | Contrato de integração RH/Folha            | IMPORTANTE  | [ ]    |

---

> **Próximo passo sugerido:** Iniciar pela Fase 1 (itens 1–4), que são independentes entre si e podem ser feitos em paralelo. Os itens 5 e 6 desbloqueiam os itens 7 e 8.
