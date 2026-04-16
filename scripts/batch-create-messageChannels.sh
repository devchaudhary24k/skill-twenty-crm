#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: POST /batch/messageChannels"
  echo "Expected JSON Body:"
  echo "[
  {
    \"createdBy\": {
      \"source\": <string>,
    },
    \"updatedBy\": {
      \"source\": <string>,
    },
    \"position\": <number>,
    \"visibility\": <string>,
    \"handle\": <string>,
    \"type\": <string>,
    \"isContactAutoCreationEnabled\": <boolean>,
    \"contactAutoCreationPolicy\": <string>,
    \"messageFolderImportPolicy\": <string>,
    \"excludeNonProfessionalEmails\": <boolean>,
    \"excludeGroupEmails\": <boolean>,
    \"pendingGroupEmailsAction\": <string>,
    \"isSyncEnabled\": <boolean>,
    \"syncCursor\": <string>,
    \"syncedAt\": <string>,
    \"syncStatus\": <string>,
    \"syncStage\": <string>,
    \"syncStageStartedAt\": <string>,
    \"throttleFailureCount\": <integer>,
    \"throttleRetryAfter\": <string>,
    \"connectedAccountId\": <string>,
  }
]"
  exit 1
}

# Check arguments
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/batch/messageChannels"

# Execute the API call
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
