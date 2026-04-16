#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: PATCH /messageFolders"
  echo "Expected JSON Body:"
  echo "{
  \"createdBy\": {
    \"source\": <string>,
  },
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"position\": <number>,
  \"name\": <string>,
  \"syncCursor\": <string>,
  \"isSentFolder\": <boolean>,
  \"isSynced\": <boolean>,
  \"parentFolderId\": <string>,
  \"externalId\": <string>,
  \"pendingSyncAction\": <string>,
  \"messageChannelId\": <string>,
}"
  exit 1
}

# Check arguments
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/messageFolders"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
