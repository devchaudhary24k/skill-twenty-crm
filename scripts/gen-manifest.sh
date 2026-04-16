#!/bin/bash
# Generate references/manifest.json from references/manifest.md.
#
# Each bullet of the form:
#   - [ ] `scripts/NAME.sh` (METHOD /path/segments)
# becomes a JSON object: {operation, script, method, path, object, category}.
#
# Non-matching lines (headings, prose, setup-section bullets with non-URL
# parentheticals) are skipped. Ordering in output matches manifest.md.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MD="$REPO_ROOT/references/manifest.md"
OUT="$REPO_ROOT/references/manifest.json"
SCRIPTS_DIR="$REPO_ROOT/scripts"

[[ -f "$MD" ]] || { echo "Error: $MD not found." >&2; exit 1; }

awk '
  BEGIN {
    # Known category prefixes, longest-first so matching is unambiguous.
    ncats = split("find-duplicates batch-create batch-restore bulk-delete bulk-update duplicate restore groupby merge create update delete list get", cats, " ")
    print "["
    first = 1
  }
  # Match: - [ ] `scripts/NAME.sh` (METHOD /path)
  match($0, /^- \[ \] `scripts\/([^`]+\.sh)` \(([a-z]+) (\/[^)]+)\)[[:space:]]*$/, m) {
    script = "scripts/" m[1]
    method = toupper(m[2])
    path   = m[3]
    op     = m[1]; sub(/\.sh$/, "", op)

    # Category: longest known prefix of operation that is followed by "-".
    category = ""
    object = ""
    for (i = 1; i <= ncats; i++) {
      prefix = cats[i] "-"
      plen   = length(prefix)
      if (substr(op, 1, plen) == prefix) {
        category = cats[i]
        object   = substr(op, plen + 1)
        break
      }
    }
    if (category == "") {
      # Outlier without a known prefix. Fall back to path-based object.
      n = split(path, parts, "/")
      for (j = n; j >= 1; j--) {
        if (parts[j] != "" && parts[j] !~ /^{.*}$/) { object = parts[j]; break }
      }
      category = "utility"
    }

    if (!first) print ","
    first = 0
    printf "  {\"operation\": \"%s\", \"script\": \"%s\", \"method\": \"%s\", \"path\": \"%s\", \"object\": \"%s\", \"category\": \"%s\"}",
      op, script, method, path, object, category
  }
  END { print ""; print "]" }
' "$MD" > "$OUT"

# Validate JSON and check counts.
if ! jq empty "$OUT" 2>/dev/null; then
  echo "Error: generated $OUT is not valid JSON." >&2
  exit 1
fi

entries=$(jq 'length' "$OUT")
unique_ops=$(jq '[.[] | .operation] | unique | length' "$OUT")
unique_scripts=$(jq '[.[] | .script] | unique | length' "$OUT")
script_count=$(find "$SCRIPTS_DIR" -maxdepth 1 -name '*.sh' \
  ! -name 'check-env.sh' ! -name 'gen-manifest.sh' \
  ! -name 'schema.sh' ! -name 'twenty.sh' | wc -l)

echo "Wrote $OUT: $entries entries."

if [[ "$entries" != "$unique_ops" ]]; then
  echo "Error: duplicate operation names in manifest (unique=$unique_ops)." >&2
  exit 2
fi
if [[ "$entries" != "$unique_scripts" ]]; then
  echo "Error: duplicate script paths in manifest (unique=$unique_scripts)." >&2
  exit 2
fi
if [[ "$entries" != "$script_count" ]]; then
  echo "Warning: manifest has $entries entries but scripts/ has $script_count endpoint scripts." >&2
fi

# Assert MCP tool-name length cap (64 chars per MCP spec).
long=$(jq -r '.[] | select(.operation | length > 64) | .operation' "$OUT")
if [[ -n "$long" ]]; then
  echo "Error: operation name(s) exceed 64 chars (MCP limit):" >&2
  echo "$long" >&2
  exit 3
fi
