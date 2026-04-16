# Contributing

## Adding a new endpoint script

1. Create `scripts/<verb>-<object>.sh` following the existing template: shebang → `source check-env.sh` → `usage()` → arg check → URL build → `curl | jq .`.
2. Add one bullet under the appropriate `## <heading>` in `references/manifest.md`:

   ```
   - [ ] `scripts/<verb>-<object>.sh` (<method> /<path>)
   ```

3. `chmod +x scripts/<verb>-<object>.sh`.
4. Regenerate the machine-readable catalog:

   ```bash
   ./scripts/gen-manifest.sh
   ```

   Commit both `manifest.md` and `manifest.json`.

## Script conventions

- Exit 1 with usage text when required args are missing.
- Path parameters go as positional args; JSON bodies go as a single quoted arg.
- Always pipe `curl` output through `jq .` for readable formatting.
- Keep operation names under 64 characters (MCP spec cap).

## Category prefixes

Known prefixes recognized by the dispatcher and manifest generator:

```
batch-create  batch-restore  bulk-delete  bulk-update
find-duplicates  merge  groupby  list  get
create  update  delete  restore  duplicate
```

Adding a new category? Append it (longest-first) to the `cats` list in `scripts/gen-manifest.sh`.

## Verification

After changes, run the smoke sweep:

```bash
# Regenerate + validate manifest
./scripts/gen-manifest.sh

# Every script produces valid-JSON schema
while read -r s; do
  ./scripts/schema.sh "$s" | jq empty || echo "FAIL: $s"
done < <(jq -r '.[].script' references/manifest.json)

# Dispatcher resolves known + unknown operations
./scripts/twenty.sh list-ops | jq 'length'
./scripts/twenty.sh xyz foo 2>&1 | grep -q "Did you mean"
```

## Regenerating after Twenty API changes

If Twenty adds new REST endpoints, generate corresponding scripts from their OpenAPI spec, append bullets to `manifest.md` under the right heading, then run `gen-manifest.sh`. The MCP server picks up new tools automatically on restart.
