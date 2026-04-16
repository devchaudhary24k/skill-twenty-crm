#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: POST /batch/workflowRuns"
  echo "Expected JSON Body:"
  echo "[
  {
    \"name\": <string>,
    \"enqueuedAt\": <string>,
    \"startedAt\": <string>,
    \"endedAt\": <string>,
    \"status\": <string>,
    \"createdBy\": {
      \"source\": <string>,
    },
    \"updatedBy\": {
      \"source\": <string>,
    },
    \"state\": {},
    \"context\": {},
    \"output\": {},
    \"position\": <number>,
    \"workflowId\": <string>,
    \"workflowVersionId\": <string>,
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
URL="${TWENTY_BASE_URL}/rest/batch/workflowRuns"

# Execute the API call
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
