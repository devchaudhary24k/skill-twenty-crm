#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> <json_payload>"
  echo "Endpoint: PATCH /messageChannels/{id}"
  echo "Expected JSON Body:"
  echo "{
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
}"
  exit 1
}

# Check arguments
ID=$1
PAYLOAD=$2
if [[ -z "$ID" || -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/messageChannels/${ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
