#!/bin/bash
# Emit a JSON Schema for a target script's input, inferred from its usage() output.
#
# Usage: scripts/schema.sh <path-to-target-script>
# Stdout: JSON Schema (object) on success; permissive fallback on parse failure.
#
# Requires python3 for structural parsing. Without python3, emits a permissive
# schema so downstream agents can still call the script (they just lose
# field-level validation).

set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <script>" >&2
  exit 1
fi
if [[ ! -f "$TARGET" ]]; then
  echo "Error: $TARGET not found." >&2
  exit 1
fi

# Capture usage text. Target scripts print usage on stdout and exit 1
# when invoked with no args; we tolerate that exit code.
USAGE="$("$TARGET" 2>&1 || true)"

if ! command -v python3 >/dev/null 2>&1; then
  echo '{"type":"object","additionalProperties":true}'
  exit 0
fi

python3 - <<'PY' "$USAGE"
import json, re, sys

usage = sys.argv[1]

def permissive():
    print(json.dumps({"type": "object", "additionalProperties": True}))
    sys.exit(0)

# ID-only scripts: Usage: $0 <company_id>  (no JSON body shown).
# Detect trailing <xxx_id> or <id> tokens in "Usage:" line and no '{'/'['.
has_json_block = re.search(r"[\{\[]", usage)
if not has_json_block:
    id_match = re.search(r"Usage:[^<\n]*<([a-zA-Z_]*id)>", usage, re.IGNORECASE)
    if id_match:
        print(json.dumps({
            "type": "object",
            "properties": {"id": {"type": "string", "description": id_match.group(1)}},
            "required": ["id"],
        }))
        sys.exit(0)
    # No args, no JSON: list/groupby/bulk-* style.
    print(json.dumps({"type": "object", "properties": {}, "additionalProperties": False}))
    sys.exit(0)

# Extract the first top-level {…} or […] block.
start = None
for i, ch in enumerate(usage):
    if ch in "{[":
        start = i
        break
if start is None:
    permissive()

opener = usage[start]
closer = "}" if opener == "{" else "]"
depth = 0
end = None
for i in range(start, len(usage)):
    c = usage[i]
    if c == opener:
        depth += 1
    elif c == closer:
        depth -= 1
        if depth == 0:
            end = i
            break
if end is None:
    permissive()

raw = usage[start:end + 1]

# Normalize pseudo-JSON used in usage text:
#   <string>/<integer>/<number>/<boolean> -> tagged literals we can transform
#   trailing commas before } or ]         -> stripped
TYPE_TOKEN = {
    "<string>": '"__T_string__"',
    "<integer>": '"__T_integer__"',
    "<number>": '"__T_number__"',
    "<boolean>": '"__T_boolean__"',
    "<object>": '"__T_object__"',
    "<array>": '"__T_array__"',
}
normalized = raw
for k, v in TYPE_TOKEN.items():
    normalized = normalized.replace(k, v)
normalized = re.sub(r",(\s*[}\]])", r"\1", normalized)

try:
    data = json.loads(normalized)
except json.JSONDecodeError:
    permissive()

TYPE_MAP = {
    "__T_string__":  {"type": "string"},
    "__T_integer__": {"type": "integer"},
    "__T_number__":  {"type": "number"},
    "__T_boolean__": {"type": "boolean"},
    "__T_object__":  {"type": "object"},
    "__T_array__":   {"type": "array"},
}

def to_schema(node):
    if isinstance(node, dict):
        props = {}
        for key, val in node.items():
            props[key] = to_schema(val)
        return {"type": "object", "properties": props, "additionalProperties": False}
    if isinstance(node, list):
        if not node:
            return {"type": "array"}
        return {"type": "array", "items": to_schema(node[0])}
    if isinstance(node, str):
        return TYPE_MAP.get(node, {"type": "string"})
    if isinstance(node, bool):
        return {"type": "boolean"}
    if isinstance(node, int):
        return {"type": "integer"}
    if isinstance(node, float):
        return {"type": "number"}
    return {}

print(json.dumps(to_schema(data)))
PY
