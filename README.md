# Twenty CRM Skill

Agent-ready toolkit for [Twenty CRM](https://twenty.com). 396 deterministic bash scripts mapped one-to-one to Twenty's REST API — CRUD, batch operations, filters, duplicate merges, and attachments across 30+ core objects.

Ships as a [Claude Code](https://docs.claude.com/en/docs/claude-code/skills) / [OpenClaw](https://github.com/openclaw) skill, and works anywhere you can run `bash`, `curl`, and `jq` — Cursor, Aider, custom agents, cron jobs, or your own terminal.

## Why this exists

Twenty CRM exposes a rich REST API, but LLM agents do poorly at composing raw HTTP calls reliably. This repo replaces guesswork with 396 named, schema-documented scripts. An agent (or a human) picks the script, passes JSON, gets a deterministic result. No token waste on API docs, no malformed requests.

## What's covered

Every Twenty object gets the full CRUD set — find, find-one, create, update, delete, batch-create, plus merge-duplicates where applicable.

- **Core CRM** — Companies, People, Opportunities, Notes, Tasks, Note Targets, Task Targets
- **Communication** — Messages, Message Threads, Message Channels, Message Participants, Message Folders
- **Calendar** — Calendar Events, Calendar Channels, Event Participants, Channel Event Associations
- **Workspace** — Workspace Members, Connected Accounts, Favorites, Favorite Folders, Blocklists
- **Automation** — Workflows, Workflow Runs, Workflow Automated Triggers, Timeline Activities
- **Content** — Attachments, Dashboards
- **…plus the long tail.** See [`references/manifest.md`](references/manifest.md) for the complete 396-endpoint list.

## Requirements

- `bash` 4+
- `curl`
- `jq`
- A Twenty CRM workspace and an API key

## Setup

Set two environment variables:

```bash
export TWENTY_BASE_URL="https://api.twenty.com"   # or your self-hosted URL
export TWENTY_API_KEY="your-api-key-here"
```

Get a key from Twenty → Settings → Developers → API Keys.

Make scripts executable on first checkout:

```bash
chmod +x scripts/*.sh
```

## Usage

### Discover available scripts

```bash
grep "people" references/manifest.md
```

### Inspect the expected JSON schema

Run any `create-*.sh` or `update-*.sh` with no arguments:

```bash
./scripts/batch-create-companies.sh
# prints: usage, endpoint, full expected JSON body with field types
```

### Execute

Path parameters are positional; JSON bodies are passed as a single argument:

```bash
# Create companies in batch
./scripts/batch-create-companies.sh '[{"name": "Acme Inc", "employees": 50}]'

# List with filter
./scripts/find-companies.sh --filter 'name[eq]:Acme Inc'

# Update one
./scripts/update-company.sh <company-id> '{"employees": 75}'

# Delete
./scripts/delete-company.sh <company-id>
```

**Always list-and-filter before creating** to avoid duplicates.

## Using with AI agents

### Claude Code

Drop the repo into `~/.claude/skills/twenty-crm/` (or anywhere Claude Code scans). The `SKILL.md` frontmatter registers it automatically. Invoke with `/twenty-master` or natural language ("add Acme to the CRM").

### OpenClaw

The `metadata.openclaw` block in `SKILL.md` declares `TWENTY_API_KEY` and `TWENTY_BASE_URL` as required env vars. OpenClaw's Docker loader wires them in from `docker-compose.yml`.

### Cursor / Aider / arbitrary agents

No special integration needed. Point the agent at this directory and tell it:

> "The `scripts/` directory contains bash tools for Twenty CRM. Run any `create-*` or `update-*` script with no args to see its JSON schema. `references/manifest.md` lists all 396 scripts."

### Raw shell / cron / CI

Scripts are standalone. Use them directly in pipelines, GitHub Actions, or scheduled jobs.

### MCP clients

See [`mcp-server/README.md`](mcp-server/README.md) for install and client config snippets (Claude Desktop, Cursor, Zed, Windsurf). Wraps all 396 scripts as MCP tools over stdio.

## Repository layout

```
.
├── SKILL.md                 # Skill manifest (Claude Code + OpenClaw)
├── scripts/                 # 396 bash scripts + check-env.sh
└── references/
    └── manifest.md          # Endpoint → script lookup table
```

## Design notes

- **One script per endpoint.** Explicit over clever. Agents can grep. Humans can read.
- **Usage text is the schema.** No separate docs to drift.
- **No state.** Every script is a single curl + jq pipeline. Safe to parallelize.
- **Auth via env only.** No config files, no secrets on disk.

## Roadmap

- [ ] Machine-readable `manifest.json` alongside `manifest.md`
- [ ] `--schema` flag for clean JSON schema on stdout
- [ ] Unified `twenty.sh <verb> <object> [args]` dispatcher
- [ ] `.env` file autoload
- [ ] Pagination helpers for `find-*` scripts

## Contributing

Scripts are generated from Twenty's OpenAPI spec, so regenerating beats hand-editing. If you find a bug, open an issue with the endpoint, payload, and the raw Twenty API response.

## License

MIT
