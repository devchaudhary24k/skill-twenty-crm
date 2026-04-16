---
name: twenty-crm
description: "Agent-ready toolkit for Twenty CRM. 396 bash scripts covering every REST endpoint — CRUD, batch operations, filters, merges, and duplicate detection across 30+ objects (Companies, People, Opportunities, Notes, Tasks, Workflows, Calendar, Messaging)."
version: 1.0.0
entrypoint: scripts/twenty.sh
manifest: references/manifest.json
requires:
  bins: [bash, curl, jq]
  env: [TWENTY_API_KEY, TWENTY_BASE_URL]
  optional_bins: [python3]
---

# Twenty CRM Skill

Deterministic bash wrappers for the Twenty CRM REST API. One script per endpoint (396 total). Each script self-documents its JSON body.

## Quick start

```bash
# Discover operations
./scripts/twenty.sh list-ops | jq '.[].operation'

# Get an input schema for any operation
./scripts/twenty.sh schema create company

# Run an operation
./scripts/twenty.sh create company '{"name":"Acme Inc"}'
./scripts/twenty.sh list people
./scripts/twenty.sh get person <id>
./scripts/twenty.sh batch-create companies '[{"name":"A"},{"name":"B"}]'
```

Also callable as raw scripts (e.g. `./scripts/list-people.sh`) for cron, CI, or agents that prefer direct invocation.

## Setup

```bash
export TWENTY_BASE_URL="https://api.twenty.com"
export TWENTY_API_KEY="your-key"
```

Or drop a `.env` file at the repo root — `scripts/check-env.sh` auto-loads it without overriding already-exported values.

## Discovery

- **`references/manifest.json`** — machine-readable catalog: `{operation, script, method, path, object, category}` for every endpoint. Regenerate with `scripts/gen-manifest.sh`.
- **`references/manifest.md`** — human-readable index grouped by action.
- **`scripts/schema.sh <script>`** — JSON Schema for any script's input (inferred from its `usage()` text).

## Agent harnesses

- **Claude Code / OpenClaw** — this `SKILL.md` is read directly. Invoke as `/twenty-crm` or via natural language.
- **MCP clients** (Claude Desktop, Cursor, Zed, Windsurf) — see `mcp-server/README.md` for a stdio server wrapping all 396 endpoints as tools.
- **Any other agent / CLI** — read `references/manifest.json`, call scripts directly with `$TWENTY_API_KEY` + `$TWENTY_BASE_URL` in env.

## Workflow notes

1. Always `list-*` with filters before `create-*` to avoid duplicates.
2. Run any `create-*.sh` or `update-*.sh` with no arguments to print its expected JSON body.
3. Path parameters (IDs) are passed as positional args. JSON bodies are a single argument.
