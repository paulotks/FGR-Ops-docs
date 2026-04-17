# Design — Redução da triplicação de UX de pop-up

## Arquivos alvo

| Arquivo | Mudança |
|---|---|
| `docs/PRD/02-jornada-usuario.md` | REQ-JOR-004 §"Comportamento de notificação": colapsar parágrafo detalhado em 2 frases de intenção + adicionar link SPEC/06 |
| `docs/PRD/03-requisitos-funcionais.md` | REQ-FUNC-013: colapsar 16 linhas em 3 frases de intenção + links SPEC/07 e SPEC/06 |
| `docs/SPEC/06-definicoes-complementares.md` | Bloco `Rastreio PRD:` da seção WebSocket: adicionar `REQ-FUNC-013` (já referenciado inline, ausente no bloco formal) |

## Sem mudanças

- `SPEC/07` — fonte canônica de UX; nenhuma mudança necessária
- `traceability.md` — REQ-IDs e SPEC apontadas não mudam; refactoring textual não altera rastreio estrutural

## Detalhe das edições

### PRD/02 — REQ-JOR-004 §Comportamento de notificação

**Antes (linhas 74–85):**
```
#### Comportamento de notificação por estado da fila

O comportamento ao chegar uma nova demanda difere conforme o estado atual da fila do operador:

- **Fila vazia** (...): o sistema dispara um **pop-up de notificação** com alerta sonoro e vibração [...] O pop-up oferece as opções **"Iniciar Agora"** ou **"Iniciar Depois (Perfilar)"**. Não há opção de recusa [...]
- **Fila não vazia**: a nova demanda entra diretamente na fila [...]

O `AdminOperacional` monitora via dashboard [...]
```

**Depois:**
```
#### Comportamento de notificação por estado da fila

Quando uma nova demanda chega a um operador com fila vazia, o sistema dispara notificação
multi-sensorial (pop-up + alerta sonoro + vibração) para garantir percepção mesmo sem tela ativa.
Quando a fila já possui demandas, a entrada é silenciosa e reordenada pelo motor de score.

[links SPEC/07 + SPEC/06 adicionados]
```

### PRD/03 — REQ-FUNC-013

**Antes (linhas 129–144):**
Texto de 16 linhas descrevendo: conteúdo do pop-up, labels dos botões, regra de não-recusa, fila ativa, admin monitoring.

**Depois:**
Parágrafo de 3 frases declarando intenção + 2 links SPEC.

### SPEC/06 — Rastreio PRD

**Antes:**
```
> **Rastreio PRD:** `REQ-NFR-002`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-ACE-005`. Decisão: DEC-017.
```

**Depois:**
```
> **Rastreio PRD:** `REQ-NFR-002`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-013`, `REQ-ACE-005`. Decisão: DEC-017.
```

## Cross-links planejados

Após a mudança, os links bidirecionais completos serão:

```
PRD/02 REQ-JOR-004 → SPEC/07#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa  (existente)
PRD/02 REQ-JOR-004 → SPEC/06#regras-de-deduplicacao-e-estado-visual                (NOVO)
PRD/03 REQ-FUNC-013 → SPEC/07#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa (existente)
PRD/03 REQ-FUNC-013 → SPEC/06#regras-de-deduplicacao-e-estado-visual               (NOVO)
SPEC/06 Rastreio PRD: REQ-FUNC-013                                                  (NOVO — faltava no bloco formal)
SPEC/07 Rastreio PRD: REQ-JOR-004, REQ-FUNC-013                                    (existente ✓)
```
