#!/bin/bash

# Validates Twenty CRM credentials for every script in scripts/.
#
# Env vars can be provided via:
#   - shell export (TWENTY_API_KEY=... TWENTY_BASE_URL=... ./scripts/...)
#   - container orchestrator (docker, kubernetes, etc.)
#   - a .env file next to this script or at the repo root
#
# .env autoload: if either var is unset and a .env file exists at
# $TWENTY_SKILL_DIR/.env or <repo>/.env, it is sourced without
# overriding already-exported values.

_twenty_autoload_env() {
  local script_dir candidates=()
  [[ -n "$TWENTY_SKILL_DIR" ]] && candidates+=("$TWENTY_SKILL_DIR/.env")
  # ${BASH_SOURCE[0]} resolves to this file whether it's executed or sourced.
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  candidates+=("$script_dir/../.env" "$script_dir/.env")

  for envfile in "${candidates[@]}"; do
    if [[ -f "$envfile" ]]; then
      set -a
      # shellcheck disable=SC1090
      source "$envfile"
      set +a
      return 0
    fi
  done
}

if [[ -z "$TWENTY_API_KEY" || -z "$TWENTY_BASE_URL" ]]; then
  _twenty_autoload_env
fi

if [[ -z "$TWENTY_API_KEY" ]]; then
  echo "Error: TWENTY_API_KEY environment variable is not set." >&2
  exit 1
fi

if [[ -z "$TWENTY_BASE_URL" ]]; then
  echo "Error: TWENTY_BASE_URL environment variable is not set." >&2
  exit 1
fi
