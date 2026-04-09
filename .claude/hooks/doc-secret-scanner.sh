#!/usr/bin/env bash
# doc-secret-scanner.sh
# Pre-edit hook: bloqueia se detectar segredos, credenciais ou PII reais em documentos

set -euo pipefail

# Ler stdin (conteúdo sendo escrito) se disponível, ou verificar arquivos staged
CONTENT=""
if [[ ! -t 0 ]]; then
  CONTENT=$(cat)
fi

BLOCKED=0

echo "=== Doc Secret Scanner ==="

check_content() {
  local source="$1"
  local text="$2"

  # API Keys e tokens reais
  if echo "$text" | grep -qE 'sk-[A-Za-z0-9]{20,}'; then
    echo "BLOCKED: Possível API key OpenAI/Anthropic (sk-...) detectada em $source" >&2
    ((BLOCKED++)) || true
  fi

  if echo "$text" | grep -qE 'pk_(live|test)_[A-Za-z0-9]{20,}'; then
    echo "BLOCKED: Possível Stripe public key (pk_live_/pk_test_...) detectada em $source" >&2
    ((BLOCKED++)) || true
  fi

  if echo "$text" | grep -qE 'AKIA[0-9A-Z]{16}'; then
    echo "BLOCKED: Possível AWS Access Key (AKIA...) detectada em $source" >&2
    ((BLOCKED++)) || true
  fi

  if echo "$text" | grep -qE 'ghp_[A-Za-z0-9]{36}'; then
    echo "BLOCKED: Possível GitHub Personal Access Token (ghp_...) detectada em $source" >&2
    ((BLOCKED++)) || true
  fi

  # JWT reais (header.payload.signature com tamanho suspeito > 100 chars)
  if echo "$text" | grep -qE 'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}'; then
    echo "BLOCKED: Possível JWT real (eyJ...) detectado em $source — use dados sintéticos" >&2
    ((BLOCKED++)) || true
  fi

  # Connection strings com credenciais reais
  if echo "$text" | grep -qiE '(Server|Data Source)=.{1,50};.*(User Id|UID)=.{1,50};.*Password=.{1,50}[^e]'; then
    echo "BLOCKED: Possível connection string com credenciais reais detectada em $source" >&2
    ((BLOCKED++)) || true
  fi

  if echo "$text" | grep -qiE 'mongodb(\+srv)?://[^:]+:[^@]+@'; then
    echo "BLOCKED: Possível MongoDB connection string com credenciais em $source" >&2
    ((BLOCKED++)) || true
  fi

  if echo "$text" | grep -qiE 'postgres(ql)?://[^:]+:[^@]+@[^/]+/'; then
    echo "BLOCKED: Possível PostgreSQL connection string com credenciais em $source" >&2
    ((BLOCKED++)) || true
  fi

  # CPF real (padrão NNN.NNN.NNN-NN)
  if echo "$text" | grep -qE '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}'; then
    echo "BLOCKED: Possível CPF real detectado em $source — use dados sintéticos" >&2
    ((BLOCKED++)) || true
  fi

  # E-mails pessoais reais (heurística: e-mails com domínios pessoais comuns que não sejam @example.com)
  if echo "$text" | grep -qiE '[a-zA-Z0-9._%+-]+@(gmail|hotmail|yahoo|outlook|icloud|live)\.(com|com\.br|net)'; then
    echo "WARNING: Possível e-mail pessoal real detectado em $source — confirme se é dado sintético" >&2
    # Warning apenas, não bloqueia
  fi

  # Caminhos de rede internos (\\server\share ou //server/share)
    if echo "$text" | grep -qE '\\\\[A-Za-z0-9_-]+\\[A-Za-z0-9_-]'; then
    echo "BLOCKED: Possível caminho de rede interno (\\\\server\\share) detectado em $source" >&2
    ((BLOCKED++)) || true
  fi
}

# Verificar conteúdo do stdin se fornecido
if [[ -n "$CONTENT" ]]; then
  check_content "stdin" "$CONTENT"
fi

# Verificar arquivos docs/ modificados recentemente (staged ou não)
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
while IFS= read -r doc_file; do
  if [[ -f "$doc_file" ]]; then
    check_content "$doc_file" "$(cat "$doc_file")"
  fi
done < <(git -C "$REPO_ROOT" diff --name-only HEAD 2>/dev/null | grep '^docs/' || true)

echo "=== Resultado: $BLOCKED bloqueio(s) ==="

if [[ $BLOCKED -gt 0 ]]; then
  echo "FAIL: $BLOCKED secret(s)/PII detectado(s). Substitua por dados sintéticos antes de continuar." >&2
  exit 2
fi

echo "OK: Nenhum segredo ou PII detectado."
exit 0
