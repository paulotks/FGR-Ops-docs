---
name: doc-audit
description: "Auditoria de consistência documental. Verifica integridade bidirecional PRD ↔ SPEC ↔ traceability.md, REQ-IDs órfãos, anchors quebrados e glossário. Acionado por /audit ou quando o usuário pede verificação de consistência."
---

# Documentation Audit Skill

Acionado por: `/audit`

## Escopo

Verificar consistência entre:
- `docs/PRD/` ↔ `docs/SPEC/` (rastreio bidirecional)
- `docs/traceability.md` (todos os REQ-IDs cobertos)
- `docs/audit/decisions-log.md` (decisões referenciadas existem)
- Glossário em `SPEC/05-backlog-mvp-glossario.md` (termos consistentes)

## Severidade

| Nível | Descrição |
|-------|-----------|
| **CRITICAL** | REQ-ID órfão (citado em SPEC mas não em PRD/_index.md), anchor morto (link → SPEC não resolve), seção SPEC sem `Rastreio PRD:` citando REQ-IDs |
| **WARNING** | Terminologia inconsistente com glossário, DEC-NNN referenciado mas não encontrado em decisions-log, diagrama linkado mas arquivo não existe em `docs/flows/` |
| **INFO** | Sugestão editorial, seção sem diagramas onde seria útil, glossário com lacunas |

## Protocolo de Execução

1. Ler `docs/PRD/_index.md` — extrair todos os REQ-IDs registrados
2. Ler `docs/SPEC/_index.md` — listar todos os módulos SPEC
3. Para cada módulo SPEC: verificar presença de `Rastreio PRD:` e que os REQ-IDs listados existem no PRD
4. Para cada módulo PRD: verificar que links `→ SPEC:` resolvem para arquivos e anchors existentes
5. Verificar `docs/traceability.md`: todos os REQ-IDs do PRD devem aparecer (diretamente ou por grupo)
6. Verificar `docs/audit/decisions-log.md`: todo `DEC-NNN` referenciado em SPECs deve existir no log
7. Verificar glossário: termos de domínio usados nas SPECs devem estar definidos
8. (Opcional) Rodar `bash .agent/workflows/scripts/traceability-validator.sh` para validação automatizada

## Formato de Saída

Para cada finding:
```
[CRITICAL|WARNING|INFO] arquivo:linha
Problema: descrição clara
Correção: ação concreta proposta
```

- Máximo 10 findings por execução (priorizar CRITICAL primeiro)
- Se tudo OK: "LGTM ✓" + resumo de cobertura atual da matriz de rastreabilidade
- Saída estruturada para fácil captura em `MEMORY/inbox.md`

## Cobertura Esperada (baseline 2026-04-10)

- REQ-IDs registrados: CTX-001…003, OBJ-001…005, SCO-001…005, SCO-F2-001…006, SCO-GAT-001…004, RBAC-001…006, JOR-001…005, FUNC-001…012, NFR-001…007, ACE-001…006 + ACE-008, MET-001…003, RISK-001…002
- Módulos SPEC: 9 + UI-DESIGN.md
- Última DEC registrada: DEC-018 | Próxima disponível: DEC-019
