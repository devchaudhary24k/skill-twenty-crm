#!/bin/bash
# Unified dispatcher for the Twenty CRM skill.
#
# Usage:
#   twenty.sh <verb> <object> [args...]          Run an endpoint script.
#   twenty.sh schema <verb> <object>             Emit JSON Schema for the endpoint.
#   twenty.sh list-ops                           Dump references/manifest.json.
#   twenty.sh --version | --help
#
# Examples:
#   twenty.sh create company '{"name":"Acme"}'
#   twenty.sh list people
#   twenty.sh get person <id>
#   twenty.sh batch-create companies '[...]'
#
# Resolution order:
#   1. scripts/<verb>-<object>.sh (direct filename match)
#   2. manifest.json lookup for operation == "<verb>-<object>"
#   3. fuzzy match → top 5 suggestions on stderr, exit 2.

set -euo pipefail

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_ROOT/references/manifest.json"

usage() {
  sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//' >&2
}

die() { echo "Error: $*" >&2; exit 2; }

suggest() {
  local op="$1"
  echo "No operation found matching '$op'." >&2
  if [[ -f "$MANIFEST" ]] && command -v jq >/dev/null 2>&1; then
    local hits
    hits="$(jq -r --arg op "$op" '
      [.[].operation]
      | map(select(contains($op[0:5]) or (. as $o | $op | contains($o[0:5]))))
      | .[0:5]
      | .[]
    ' "$MANIFEST" 2>/dev/null || true)"
    if [[ -n "$hits" ]]; then
      echo "Did you mean:" >&2
      echo "$hits" | sed 's/^/  /' >&2
    fi
  fi
  exit 2
}

case "${1:-}" in
  ""|-h|--help)
    usage; exit 0 ;;
  -v|--version)
    echo "twenty-crm-skill $VERSION"; exit 0 ;;
  list-ops)
    [[ -f "$MANIFEST" ]] || die "Manifest not found: $MANIFEST (run scripts/gen-manifest.sh)."
    cat "$MANIFEST"; exit 0 ;;
  schema)
    shift
    [[ $# -ge 2 ]] || die "Usage: twenty.sh schema <verb> <object>"
    verb="$1"; object="$2"
    target="$SCRIPT_DIR/${verb}-${object}.sh"
    if [[ -f "$target" ]]; then
      exec "$SCRIPT_DIR/schema.sh" "$target"
    fi
    suggest "${verb}-${object}"
    ;;
esac

[[ $# -ge 2 ]] || { usage; exit 2; }

VERB="$1"; OBJECT="$2"; shift 2
OP="${VERB}-${OBJECT}"
TARGET="$SCRIPT_DIR/${OP}.sh"

if [[ ! -f "$TARGET" ]]; then
  # Manifest fallback (useful if a future script is named off-convention).
  if [[ -f "$MANIFEST" ]] && command -v jq >/dev/null 2>&1; then
    alt="$(jq -r --arg op "$OP" '.[] | select(.operation == $op) | .script' "$MANIFEST" | head -1)"
    if [[ -n "$alt" && -f "$REPO_ROOT/$alt" ]]; then
      TARGET="$REPO_ROOT/$alt"
    fi
  fi
fi

if [[ ! -f "$TARGET" ]]; then
  suggest "$OP"
fi

exec "$TARGET" "$@"
