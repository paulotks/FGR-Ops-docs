#!/usr/bin/env bash
# traceability-validator.sh
# Adaptado de .claude/hooks/traceability-validator.sh para uso em .agent/workflows/
# Executar a partir da raiz do repositório: bash .agent/workflows/scripts/traceability-validator.sh

set -euo pipefail

# REPO_ROOT: 3 níveis acima de scripts/
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PRD_INDEX="$REPO_ROOT/docs/PRD/_index.md"
TRACEABILITY="$REPO_ROOT/docs/traceability.md"
SPEC_DIR="$REPO_ROOT/docs/SPEC"
PRD_DIR="$REPO_ROOT/docs/PRD"

ERRORS=0
WARNINGS=0

echo "=== Traceability Validator ==="

# --- 1. Coletar todos os REQ-IDs registrados no PRD _index.md ---
if [[ ! -f "$PRD_INDEX" ]]; then
  echo "ERROR: docs/PRD/_index.md não encontrado" >&2
  exit 2
fi

REGISTERED_IDS=$(grep -oE 'REQ-[A-Z]+-[0-9]+' "$PRD_INDEX" | sort -u || true)

# --- 2. Verificar REQ-IDs citados em SPEC que existem no índice PRD ---
echo ""
echo ">> Verificando REQ-IDs em SPEC..."
while IFS= read -r spec_file; do
  cited=$(grep -oE 'REQ-[A-Z]+-[0-9]+' "$spec_file" | sort -u || true)
  for req_id in $cited; do
    if ! echo "$REGISTERED_IDS" | grep -qF "$req_id"; then
      echo "  ORPHAN REQ-ID: $req_id citado em $(basename "$spec_file") mas não encontrado em PRD/_index.md" >&2
      ((ERRORS++)) || true
    fi
  done

  if echo "$cited" | grep -qE 'REQ-'; then
    if ! grep -q 'Rastreio PRD' "$spec_file"; then
      echo "  MISSING RASTREIO: $(basename "$spec_file") cita REQ-IDs mas não tem bloco 'Rastreio PRD:'" >&2
      ((ERRORS++)) || true
    fi
  fi
done < <(find "$SPEC_DIR" -name "*.md" -type f 2>/dev/null)

# --- 3. Verificar cross-links PRD → SPEC (→ SPEC: path#anchor) ---
echo ""
echo ">> Verificando cross-links PRD → SPEC..."
while IFS= read -r prd_file; do
  while IFS= read -r link; do
    rel_path=$(echo "$link" | grep -oE '\(\.\./SPEC/[^)#]+#[^)]+\)' | tr -d '()' || true)
    if [[ -z "$rel_path" ]]; then
      rel_path=$(echo "$link" | grep -oE '\.\./SPEC/[^ ]+#[^ ]+' || true)
    fi
    if [[ -n "$rel_path" ]]; then
      file_part="${rel_path%%#*}"
      abs_file="$PRD_DIR/$file_part"
      abs_file=$(realpath -m "$abs_file" 2>/dev/null || echo "$abs_file")
      if [[ ! -f "$abs_file" ]]; then
        echo "  BROKEN LINK: $link em $(basename "$prd_file") — arquivo não encontrado: $file_part" >&2
        ((ERRORS++)) || true
      fi
    fi
  done < <(grep -E '→ SPEC:|-> SPEC:' "$prd_file" || true)
done < <(find "$PRD_DIR" -name "*.md" -type f 2>/dev/null)

# --- 4. Verificar que traceability.md contém os REQ-IDs do PRD ---
echo ""
echo ">> Verificando cobertura em traceability.md..."
if [[ -f "$TRACEABILITY" ]]; then
  for req_id in $REGISTERED_IDS; do
    if ! grep -qF "$req_id" "$TRACEABILITY"; then
      prefix=$(echo "$req_id" | grep -oE 'REQ-[A-Z]+-' || true)
      if ! grep -qE "${prefix}\*|${req_id}" "$TRACEABILITY"; then
        echo "  WARNING: $req_id não encontrado explicitamente em traceability.md" >&2
        ((WARNINGS++)) || true
      fi
    fi
  done
else
  echo "  WARNING: docs/traceability.md não encontrado" >&2
  ((WARNINGS++)) || true
fi

# --- Resultado ---
echo ""
echo "=== Resultado: $ERRORS erro(s), $WARNINGS aviso(s) ==="

if [[ $ERRORS -gt 0 ]]; then
  echo "FAIL: $ERRORS inconsistência(s) de rastreabilidade encontrada(s). Corrija antes de continuar." >&2
  exit 2
fi

if [[ $WARNINGS -gt 0 ]]; then
  echo "WARN: $WARNINGS aviso(s). Verifique e documente se intencional."
fi

echo "OK: Rastreabilidade validada."
exit 0
