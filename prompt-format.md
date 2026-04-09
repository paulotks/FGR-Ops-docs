Você vai me ajudar a configurar o pipeline neuro-simbólico do Claude Code neste projeto de **documentação**.

## CONTEXTO

Este repositório (`FGR-Ops-Requisitos`) é **exclusivamente** para documentação: PRD, SPEC, ADRs, diagramas operacionais e matriz de rastreabilidade do sistema **FGR-OPS** (Machinery Link). **Nenhum código de produto** (`.ts`, `.prisma`, `.tsx`, controllers, use-cases, componentes) é escrito aqui. Skills táticas em `.agent/skills/` servem apenas como referência arquitetural para redação das SPECs — não para implementação.

Arquivos de apoio já presentes na raiz:
- `cheatsheet.md` — referência rápida do pipeline neuro-simbólico
- `claude-md-starter.md` — template CLAUDE.md (originalmente orientado a código; será adaptado)
- `CLAUDE.md` — já existe e define a constraint de documentação. Este prompt **atualiza / estende** o existente, não sobrescreve a constraint fundamental.

## MEU PROJETO

- **Nome:** FGR Ops Requisitos (documentação do sistema FGR-OPS — Machinery Link MVP)
- **Natureza:** Repositório documentation-only (PRD + SPEC + ADRs)
- **Diretório raiz:** `C:\dev\FGR-Ops-Requisitos`
- **Fonte única da verdade:** `docs/` (raiz contém apenas stubs `PRD-FGR-OPS.md` e `FGR-OPS-SPEC.md`)
- **Estrutura documental:**
  - `docs/PRD/_index.md` — índice PRD e registro de REQ-IDs
  - `docs/SPEC/_index.md` — índice SPEC e overview arquitetural
  - `docs/traceability.md` — **matriz global** (atualização obrigatória a cada mudança PRD/SPEC)
  - `docs/flows/` — diagramas operacionais Mermaid
  - `docs/audit/decisions-log.md` — decisões arquiteturais (`DEC-NNN`)
  - `docs/changes/` — pacotes de mudança ativos
  - `docs/INFRA.md` — setup de infraestrutura e ambiente
  - `docs/UI-DESIGN.md` — design system e especificações visuais

## SUA TAREFA (executar na ordem)

### FASE 1 — CLAUDE.md (Sistema Operacional do Contexto documental)

Leia o `claude-md-starter.md` e o `CLAUDE.md` já existente. **Adapte** o starter para um projeto de documentação (o starter original é orientado a código; remova/substitua seções de Stack/Tests/Lint por equivalentes documentais). Consolide tudo no `CLAUDE.md` da raiz preservando a constraint fundamental ("documentation-only repository").

Preencha TODOS os campos com dados reais:

1. **Identity:** "FGR Ops Requisitos — repositório documentation-only do sistema FGR-OPS (Machinery Link MVP, plataforma multi-tenant de operações de maquinário pesado para obras da FGR Incorporações)"
2. **Documentation Stack** (não "tech stack"):
   - Formato: Markdown + front-matter YAML quando aplicável
   - Diagramas: Mermaid (fluxos operacionais, ER, sequência)
   - Rastreabilidade: matriz global `docs/traceability.md`
   - Decisões: ADRs em `docs/audit/decisions-log.md` (`DEC-NNN`) + ADRs arquiteturais `D1–D7` nas SPECs
   - Workflow de mudanças: pacotes em `docs/changes/` (OpsX: propose → apply → archive)
3. **Target system stack** (somente como contexto para redação das SPECs, NÃO para implementar aqui):
   - Frontend: Angular 20 PWA (mobile-first)
   - Backend: NestJS 10+ REST, Turborepo monorepo, pnpm 9.x
   - DB: SQL Server 2019+ via Prisma ORM (multi-tenancy lógico via `obraId`)
   - Auth: JWT access 15 min + refresh 7d/12h, Redis blacklist, RBAC
4. **Mandatory Rules** (mínimo 8, todas sobre documentação):
   - Nunca criar ou editar código-fonte de produto (`.ts`, `.prisma`, `.tsx`, controllers, use-cases, componentes) neste repo
   - Sempre usar prefixes padrão: `REQ-<PREFIX>-<NNN>` com `FUNC`, `NFR`, `ACE`, `RBAC`, `JOR`, `CTX`, `OBJ`, `MET`, `RISK`
   - Toda seção SPEC que referencia requisitos PRD deve incluir um bloco `**Rastreio PRD:**` listando os `REQ-xxx`
   - Decisões táticas → `DEC-<NNN>` em `docs/audit/decisions-log.md`; ADRs arquiteturais em SPEC → `D1–D7`
   - Cross-links obrigatórios: PRD → SPEC usando `→ SPEC: relative-path#anchor`; SPEC → PRD usando bloco `Rastreio PRD:`
   - Atualizar `docs/traceability.md` é **deliverable mandatório** sempre que PRD ou SPEC forem alterados de forma estável
   - Toda mudança não-trivial deve passar pelo workflow OpsX em `docs/changes/` (propose → apply → archive)
   - Diagramas de fluxo sempre em Mermaid dentro de `docs/flows/` e linkados do SPEC correspondente
5. **Routing Table** (mínimo 6 situações → ação):
   - "Novo requisito funcional" → criar `REQ-FUNC-NNN` em `docs/PRD/`, atualizar `_index.md`, gerar ou atualizar seção SPEC correspondente, atualizar `traceability.md`
   - "Nova decisão arquitetural" → registrar `DEC-NNN` em `docs/audit/decisions-log.md` e referenciar do SPEC
   - "Novo fluxo operacional" → criar diagrama Mermaid em `docs/flows/`, linkar de PRD e SPEC
   - "Mudança em requisito existente" → abrir pacote em `docs/changes/`, seguir OpsX, atualizar `traceability.md` ao finalizar
   - "Novo conceito de domínio" → documentar em SPEC domain model, adicionar entrada em glossário, atualizar ER se necessário
   - "Ambiguidade entre PRD e SPEC" → abrir auditoria via `/audit`, propor resolução, registrar `DEC-NNN` se arquitetural
   - "Novo perfil/permissão" → atualizar seção RBAC do PRD, atualizar matriz de permissões do SPEC
6. **Quality Gates** (checklist obrigatório para toda mudança documental):
   - Rodar `/audit` — zero inconsistências não-justificadas
   - `docs/traceability.md` reflete o estado atual (sem REQ-IDs órfãos, sem SPECs sem rastreio)
   - Todo `REQ-<PREFIX>-<NNN>` novo está registrado em `docs/PRD/_index.md`
   - Todo cross-link PRD↔SPEC é bidirecional e resolve (anchor existe)
   - Diagramas Mermaid renderizam sem erro de sintaxe
   - Decisões táticas registradas em `DEC-NNN`; ADRs arquiteturais em `D1–D7`
   - Glossário de termos de domínio está consistente com o texto das SPECs
7. **Forbidden** (mínimo 6 proibições):
   - NUNCA criar ou editar arquivos de código-fonte de produto neste repositório
   - NUNCA inventar `REQ-ID` sem registrá-lo em `docs/PRD/_index.md`
   - NUNCA quebrar a constraint bidirecional de rastreio (SPEC sem `Rastreio PRD:` ou PRD sem `→ SPEC:`)
   - NUNCA remover entradas históricas do `decisions-log.md` (decisões são append-only; supersedê-las explicitamente)
   - NUNCA commitar pacote de mudança OpsX parcial sem rodar `/audit`
   - NUNCA usar placeholders tipo "TBD"/"TODO" em documentos marcados como estáveis sem abrir entry em `MEMORY/inbox.md`
   - NUNCA expor segredos, credenciais ou PII reais em documentos de exemplo
8. **Current State:** Descreva o estado atual do projeto a partir do que for encontrado em `docs/PRD/_index.md`, `docs/SPEC/_index.md`, `docs/traceability.md`, e últimos commits. Nada de placeholders — leia os arquivos.

### FASE 2 — Hooks de Enforcement (3 hooks essenciais, orientados a documentação)

Crie a pasta `.claude/hooks/` e adicione:

**Hook 1: traceability-validator.sh**
Roda após edições em `docs/PRD/**` ou `docs/SPEC/**`. Verifica:
- Todo `REQ-<PREFIX>-<NNN>` citado em SPEC existe em `docs/PRD/_index.md`
- Toda seção SPEC que menciona REQ tem o bloco `**Rastreio PRD:**`
- Todo PRD com `→ SPEC: path#anchor` resolve para anchor existente
- `docs/traceability.md` contém os REQ-IDs tocados na sessão
- Falha (exit 2) se encontrar REQ-ID órfão ou cross-link quebrado

**Hook 2: doc-secret-scanner.sh**
Pre-edit hook. Bloqueia se detectar em qualquer documento:
- API keys ou tokens reais (padrões: `sk-`, `pk_`, `AKIA`, `ghp_`, `eyJ...` longos que pareçam JWT reais)
- Connection strings com credenciais reais (`Server=...;User Id=...;Password=...`)
- CPFs, e-mails pessoais, telefones reais em exemplos (sugerir dados sintéticos)
- Caminhos de rede internos que vazem infra não documentada

**Hook 3: session-end.sh**
Roda no final da sessão (evento `Stop`). Automaticamente:
- Atualiza `MEMORY/wake-up.md` com o estado corrente (últimos REQ/DEC tocados, pacotes OpsX ativos)
- Adiciona entry em `MEMORY/journal.md` com timestamp, arquivos alterados, decisões registradas
- Lista TODOs pendentes lendo `MEMORY/inbox.md` e marcadores `TBD`/`TODO` encontrados
- Lembra de rodar `/audit` se houve edição em `docs/PRD/` ou `docs/SPEC/` sem matriz de rastreio atualizada

Depois configure o `.claude/settings.json` para ativar os hooks (usar o formato com `matcher` mostrado no `cheatsheet.md`):
```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "bash .claude/hooks/doc-secret-scanner.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "bash .claude/hooks/traceability-validator.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "bash .claude/hooks/session-end.sh" }] }
    ]
  }
}
```

### FASE 3 — Memória Persistente (4 arquivos)

Crie a pasta `MEMORY/` na raiz do projeto:

1. **MEMORY/wake-up.md** — Estado atual da documentação
   - Últimos REQ-IDs e DEC-IDs adicionados / modificados
   - Pacotes OpsX ativos em `docs/changes/`
   - Seções de PRD ou SPEC atualmente "em revisão" ou "instáveis"
   - "Quando Claude inicia sessão, lê este arquivo primeiro"

2. **MEMORY/journal.md** — Log cronológico
   - Formato: `## YYYY-MM-DD\n- Arquivos alterados\n- REQ/DEC registrados\n- Decisões tomadas`
   - Novo entry a cada sessão

3. **MEMORY/decisions.md** — Espelho leve das decisões táticas
   - NÃO substitui `docs/audit/decisions-log.md` — apenas aponta para os `DEC-NNN` mais relevantes da sessão atual
   - Formato ADR simplificado: Contexto → Decisão → Consequências → Link canônico para `decisions-log.md`

4. **MEMORY/inbox.md** — Tasks documentais pendentes
   - TODOs que surgiram durante sessões (ex: "REQ-FUNC-042 menciona SLA mas falta seção no SPEC")
   - Ambiguidades detectadas por `/audit` ainda não resolvidas
   - Claude lê e sugere qual atacar a cada nova sessão

### FASE 4 — MCP Server (opcional mas poderoso)

Se fizer sentido para busca semântica na documentação, configure MCPs úteis para este contexto documental no `.claude/settings.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "C:/dev/FGR-Ops-Requisitos/docs"]
    }
  }
}
```

O foco é busca semântica em `docs/` — não execução de código. Evite MCPs orientados a banco de dados, terminais remotos ou execução, pois não há código a executar neste repo.

### FASE 5 — Skills (2 skills essenciais, documentais)

Crie (ou atualize) `.claude/skills/` e adicione:

**Skill 1: spec-authoring.md**
```markdown
# SPEC Authoring Skill
1. Antes de escrever qualquer SPEC, leia o PRD correspondente e anote os REQ-IDs relevantes
2. Toda seção nova deve começar com o bloco `**Rastreio PRD:**` listando REQ-IDs
3. Para cada decisão arquitetural tomada ao escrever, registre em `docs/audit/decisions-log.md` como `DEC-NNN`
4. Atualize `docs/traceability.md` antes de considerar a seção estável
5. Use a referência tática em `.agent/skills/` apenas para entender o pattern (não copie código para dentro da SPEC)
6. Diagramas sempre em Mermaid, armazenados em `docs/flows/` e linkados por path relativo
```

**Skill 2: doc-audit.md**
```markdown
# Documentation Audit Skill
1. Escopo: verificar consistência PRD ↔ SPEC ↔ traceability.md ↔ decisions-log.md
2. Severidade: CRITICAL (rastreio quebrado / REQ-ID órfão / anchor morto) | WARNING (terminologia inconsistente / glossário defasado) | INFO (sugestão editorial)
3. Para cada finding: arquivo:linha + descrição + correção concreta proposta
4. Máximo 10 findings por execução (priorize CRITICAL primeiro)
5. Se tudo OK: "LGTM" + resumo de cobertura atual da matriz de rastreabilidade
6. Saída estruturada para fácil consumo por `MEMORY/inbox.md`
```

### FASE 6 — Validação (faça AGORA)

Verifique que tudo está configurado:
1. Ler `CLAUDE.md` → deve conter identity, documentation stack, target stack (contextual), mandatory rules, routing, gates, forbidden, current state
2. Listar `.claude/hooks/` → deve ter os 3 scripts documentais (traceability-validator, doc-secret-scanner, session-end)
3. Listar `MEMORY/` → deve ter 4 arquivos inicializados com estado real (lido de `docs/`)
4. Listar `.claude/skills/` → deve ter spec-authoring e doc-audit
5. Iniciar uma sessão de teste e pedir: "Leia o CLAUDE.md e liste as 3 coisas que você NUNCA fará neste repo"
6. Claude deve responder citando: (a) não criar código-fonte de produto, (b) não quebrar rastreio PRD↔SPEC, (c) não inventar REQ-ID sem registrar
7. Pedir "/audit" seco e confirmar que o skill doc-audit é acionado

### FASE 7 — Fluxo Diário (ongoing)

A cada nova sessão de trabalho documental:
1. Claude lê `MEMORY/wake-up.md` automaticamente
2. Claude checa `MEMORY/inbox.md` por pendências documentais
3. Trabalha seguindo as regras de `CLAUDE.md` (incluindo a constraint documentation-only)
4. Hooks validam rastreabilidade e segredos em tempo real
5. Antes de encerrar, `session-end.sh` atualiza `wake-up.md`, `journal.md` e lembra de rodar `/audit`

## REGRAS DE QUALIDADE

- `CLAUDE.md` deve ter pelo menos 8 mandatory rules (todas documentais)
- Routing table com pelo menos 6 situações mapeadas, todas de natureza documental
- Quality gates devem incluir pelo menos: `/audit`, matriz de rastreio atualizada, cross-links bidirecionais
- Hooks devem ser executáveis em bash no Git Bash do Windows (shebang `#!/usr/bin/env bash`)
- `MEMORY/` deve ser inicializada com estado real lido de `docs/` (não placeholder)
- Forbidden deve incluir pelo menos: criação de código de produto, REQ-ID inventado, quebra de rastreio bidirecional, segredos/PII reais em exemplos
- Nada neste pipeline deve incentivar ou facilitar a escrita de código-fonte de produto no repositório

## OUTPUT ESPERADO

Após todas as fases:
1. `CLAUDE.md` atualizado na raiz, preservando e reforçando a constraint documentation-only
2. 3 hooks funcionais em `.claude/hooks/` (traceability-validator, doc-secret-scanner, session-end)
3. 4 arquivos de memória em `MEMORY/` populados com estado real
4. `.claude/settings.json` com hooks configurados (e MCP filesystem opcional apontando para `docs/`)
5. 2 skills em `.claude/skills/` (spec-authoring, doc-audit)
6. Claude seguindo automaticamente: constraint documentation-only + rastreabilidade bidirecional + workflow OpsX

Comece pela FASE 1. **Antes de qualquer coisa**, leia o `CLAUDE.md` atual, `claude-md-starter.md`, `docs/PRD/_index.md`, `docs/SPEC/_index.md` e `docs/traceability.md` para não sobrescrever contexto existente. Depois atualize o `CLAUDE.md` preservando a constraint fundamental.
