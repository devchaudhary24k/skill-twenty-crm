#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> <json_payload>"
  echo "Endpoint: PATCH /restore/messageFolders/{id}"
  exit 1
}

# Check arguments
ID=$1
PAYLOAD=$2
if [[ -z "$ID" || -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/restore/messageFolders/${ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
