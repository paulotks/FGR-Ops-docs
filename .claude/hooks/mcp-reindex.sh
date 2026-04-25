#!/usr/bin/env bash
# mcp-reindex.sh
# PostToolUse: reindexes fgr-docs-mcp SQLite DB after any docs/**/*.md edit

INPUT=""
if [[ ! -t 0 ]]; then
  INPUT=$(cat)
fi

# Only run when a file under docs/ was touched
if ! echo "$INPUT" | grep -qiE '[/\\]docs[/\\]'; then
  exit 0
fi

INDEXER="C:/dev/fgr-docs-mcp/dist/indexer.js"
if [[ ! -f "$INDEXER" ]]; then
  echo "[mcp-reindex] AVISO: indexer não encontrado em $INDEXER" >&2
  exit 0
fi

echo "[mcp-reindex] Reindexando banco de documentação..."
node "$INDEXER" "C:/dev/FGR-Ops-docs/docs" 2>&1 | tail -2
