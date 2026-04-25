#!/usr/bin/env bash
# session-end.sh
# Roda no evento Stop. Atualiza MEMORY/ com estado da sessão.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MEMORY_DIR="$REPO_ROOT/MEMORY"
WAKE_UP="$MEMORY_DIR/wake-up.md"
JOURNAL="$MEMORY_DIR/journal.md"
INBOX="$MEMORY_DIR/inbox.md"
DECISIONS_LOG="$REPO_ROOT/docs/audit/decisions-log.md"
TRACEABILITY="$REPO_ROOT/docs/traceability.md"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
DATE=$(date '+%Y-%m-%d')

mkdir -p "$MEMORY_DIR"

echo "=== Session End Hook ==="

# --- Coletar arquivos alterados nesta sessão ---
CHANGED_FILES=$(git -C "$REPO_ROOT" diff --name-only HEAD 2>/dev/null || true)
STAGED_FILES=$(git -C "$REPO_ROOT" diff --name-only --cached 2>/dev/null || true)
ALL_CHANGED=$(echo -e "$CHANGED_FILES\n$STAGED_FILES" | sort -u | grep -v '^$' || true)

# --- Coletar últimos DEC-IDs do decisions-log ---
LAST_DECS=""
if [[ -f "$DECISIONS_LOG" ]]; then
  LAST_DECS=$(grep -oE 'DEC-[0-9]+' "$DECISIONS_LOG" | sort -u | tail -5 | tr '\n' ', ' | sed 's/,$//' || true)
fi

# --- Verificar REQ-IDs tocados ---
TOUCHED_REQS=""
if [[ -n "$ALL_CHANGED" ]]; then
  TOUCHED_REQS=$(echo "$ALL_CHANGED" | xargs -I{} grep -hoE 'REQ-[A-Z]+-[0-9]+' "$REPO_ROOT/{}" 2>/dev/null | sort -u | tr '\n' ', ' | sed 's/,$//' || true)
fi

# --- Verificar pacotes OpsX ativos ---
ACTIVE_PACKAGES=""
if [[ -d "$REPO_ROOT/docs/changes" ]]; then
  ACTIVE_PACKAGES=$(find "$REPO_ROOT/docs/changes" -maxdepth 1 -name "*.md" -not -name "README.md" 2>/dev/null | xargs -I{} basename {} .md | tr '\n' ', ' | sed 's/,$//' || true)
fi

# --- Verificar TBD/TODO em docs/ ---
PENDING_TBDS=$(grep -rn 'TBD\|TODO' "$REPO_ROOT/docs/" --include="*.md" 2>/dev/null | head -10 || true)

# --- Verificar se houve edição PRD/SPEC sem atualizar traceability ---
NEED_TRACEABILITY_WARN=false
if echo "$ALL_CHANGED" | grep -qE '^docs/(PRD|SPEC)/'; then
  # Verificar se traceability.md também foi tocado
  if ! echo "$ALL_CHANGED" | grep -q 'traceability.md'; then
    NEED_TRACEABILITY_WARN=true
  fi
fi

# --- Atualizar wake-up.md ---
cat > "$WAKE_UP" << WAKEUP
# MEMORY/wake-up.md — Estado da Documentação

> Leia este arquivo no início de cada sessão para retomar contexto.

**Atualizado em:** $TIMESTAMP

## Últimos REQ-IDs / DEC-IDs Tocados

- **DEC-IDs recentes:** ${LAST_DECS:-"(nenhum identificado nesta sessão)"}
- **REQ-IDs tocados:** ${TOUCHED_REQS:-"(nenhum identificado nesta sessão)"}

## Pacotes OpsX Ativos (docs/changes/)

${ACTIVE_PACKAGES:-"Nenhum pacote ativo — docs/changes/ está limpo."}

## Seções PRD/SPEC em Revisão

$(if [[ -n "$ALL_CHANGED" ]]; then echo "$ALL_CHANGED" | grep -E '^docs/(PRD|SPEC)/' || echo "(nenhuma mudança PRD/SPEC nesta sessão)"; else echo "(nenhuma mudança PRD/SPEC nesta sessão)"; fi)

## Alertas

$(if [[ "$NEED_TRACEABILITY_WARN" == "true" ]]; then echo "⚠️  ATENÇÃO: Arquivos PRD/SPEC foram editados mas docs/traceability.md não foi atualizado. Rode /audit antes de encerrar."; fi)
$(if [[ -n "$PENDING_TBDS" ]]; then echo "⚠️  TBD/TODO encontrados em docs/ — revise MEMORY/inbox.md"; fi)

## Próxima DEC Disponível

$(grep -oE 'DEC-[0-9]+' "$DECISIONS_LOG" 2>/dev/null | grep -oE '[0-9]+' | sort -n | tail -1 | awk '{printf "DEC-%03d\n", $1+1}' || echo "DEC-011")

## Referências Rápidas

- [Índice PRD](docs/PRD/_index.md)
- [Índice SPEC](docs/SPEC/_index.md)
- [Traceability](docs/traceability.md)
- [Decisions Log](docs/audit/decisions-log.md)
- [Changes](docs/changes/)
WAKEUP

echo ">> wake-up.md atualizado"

# --- Adicionar entry ao journal.md ---
JOURNAL_ENTRY="## $DATE

**Sessão encerrada em:** $TIMESTAMP

### Arquivos Alterados

$(if [[ -n "$ALL_CHANGED" ]]; then echo "$ALL_CHANGED" | sed 's/^/- /'; else echo "- (nenhum arquivo alterado)"; fi)

### REQ-IDs Tocados

${TOUCHED_REQS:-"(nenhum)"}

### DEC-IDs Registrados

${LAST_DECS:-"(nenhum novo nesta sessão)"}

### Decisões Tomadas

(Registrar manualmente se houve decisões táticas importantes)

---
"

# Prepend ao journal (manter cronologia reversa)
if [[ -f "$JOURNAL" ]]; then
  EXISTING=$(cat "$JOURNAL")
  # Verificar se já existe entry para hoje
  if ! grep -q "^## $DATE$" "$JOURNAL"; then
    echo "$JOURNAL_ENTRY" > "$JOURNAL"
    echo "$EXISTING" >> "$JOURNAL"
  fi
else
  echo "# MEMORY/journal.md — Log Cronológico de Sessões" > "$JOURNAL"
  echo "" >> "$JOURNAL"
  echo "$JOURNAL_ENTRY" >> "$JOURNAL"
fi

echo ">> journal.md atualizado"

# --- Atualizar inbox.md com TBDs encontrados ---
if [[ -n "$PENDING_TBDS" ]]; then
  if [[ -f "$INBOX" ]]; then
    echo "" >> "$INBOX"
    echo "## Tasks detectadas em $DATE" >> "$INBOX"
    echo "" >> "$INBOX"
    echo "$PENDING_TBDS" | while IFS= read -r line; do
      echo "- [ ] $line" >> "$INBOX"
    done
  fi
fi

echo ">> inbox.md verificado"

# --- Lembrete final ---
echo ""
echo "=== Resumo da Sessão ==="
echo "Data: $DATE"
echo "Arquivos alterados: $(echo "$ALL_CHANGED" | grep -c . || echo 0)"
echo "DEC-IDs recentes: ${LAST_DECS:-none}"

if [[ "$NEED_TRACEABILITY_WARN" == "true" ]]; then
  echo ""
  echo "⚠️  LEMBRETE: docs/traceability.md precisa ser atualizado!"
  echo "   Rode /audit para verificar inconsistências."
fi

# --- Re-index MCP server se há mudanças não-commitadas em docs/ ---
DOCS_CHANGED=$(echo "$ALL_CHANGED" | grep '^docs/' || true)
if [[ -n "$DOCS_CHANGED" ]]; then
  INDEXER="C:/dev/fgr-docs-mcp/dist/indexer.js"
  if [[ -f "$INDEXER" ]]; then
    echo ""
    echo "[fgr-docs-mcp] Mudanças não-commitadas em docs/ — re-indexando MCP..."
    node "$INDEXER" "C:/dev/FGR-Ops-docs/docs" 2>&1 | tail -4
    echo "[fgr-docs-mcp] Pronto."
  else
    echo "[fgr-docs-mcp] AVISO: dist/indexer.js não encontrado — execute 'npm run build' em C:/dev/fgr-docs-mcp"
  fi
fi

echo ""
echo "OK: Session end hook concluído."
exit 0
