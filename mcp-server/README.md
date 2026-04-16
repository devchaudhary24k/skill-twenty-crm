# Twenty CRM — MCP server

Exposes all 396 Twenty CRM operations as MCP tools over stdio. Any MCP-capable client (Claude Desktop, Cursor, Zed, Windsurf, custom SDK) can invoke them without shelling out manually.

## Install

```bash
pip install -r mcp-server/requirements.txt
# or
pipx install mcp
```

Requires Python 3.10+.

## Environment

Set the same two variables the scripts use:

```bash
export TWENTY_API_KEY=...
export TWENTY_BASE_URL=https://api.twenty.com
```

Optional — narrow the exposed tool list (some MCP clients stall on 400 tools):

```bash
export TWENTY_MCP_FILTER='^(list|get|create|update|delete)-(people|companies|opportunities)$'
```

The value is a Python regex applied to each `operation` name.

## Run

```bash
python3 mcp-server/server.py
```

Prerequisite: `references/manifest.json` must exist. If missing, run:

```bash
./scripts/gen-manifest.sh
```

## Client configuration

### Claude Desktop — `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "twenty-crm": {
      "command": "python3",
      "args": ["/absolute/path/to/openclaw-twentrycrm/mcp-server/server.py"],
      "env": {
        "TWENTY_API_KEY": "...",
        "TWENTY_BASE_URL": "https://api.twenty.com"
      }
    }
  }
}
```

### Cursor — `~/.cursor/mcp.json`

Same shape as Claude Desktop.

### Zed — `settings.json`

```json
"context_servers": {
  "twenty-crm": {
    "command": {
      "path": "python3",
      "args": ["/absolute/path/to/openclaw-twentrycrm/mcp-server/server.py"]
    },
    "env": {
      "TWENTY_API_KEY": "...",
      "TWENTY_BASE_URL": "https://api.twenty.com"
    }
  }
}
```

### Windsurf — `~/.codeium/windsurf/mcp_config.json`

Same shape as Claude Desktop.

## Tool shape

Each MCP tool corresponds to one entry in `references/manifest.json`.

- **Name** — the `operation` field (e.g. `batch-create-companies`, `list-people`, `get-company`).
- **Description** — `<METHOD> <path>` (e.g. `POST /batch/companies`).
- **Input** — always an object with a single `payload` property. The inner schema is inferred from each script's `usage()` output via `scripts/schema.sh`. For ID-only endpoints, `payload.id` is required. For list/groupby endpoints, `payload` is an empty object.

## Troubleshooting

- **`manifest not found`** — run `./scripts/gen-manifest.sh` once.
- **Tool count too large for client** — set `TWENTY_MCP_FILTER`.
- **Permissive schemas** on some tools — the inferred schema fell back to `additionalProperties: true`. Safe; agents can still call with any JSON.
- **`command not found: jq`** — scripts require `jq`. Install: `brew install jq` or `apt install jq`.
