#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> <json_payload>"
  echo "Endpoint: PATCH /favorites/{id}"
  echo "Expected JSON Body:"
  echo "{
  \"createdBy\": {
    \"source\": <string>,
  },
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"position\": <number>,
  \"viewId\": <string>,
  \"companyId\": <string>,
  \"dashboardId\": <string>,
  \"forWorkspaceMemberId\": <string>,
  \"personId\": <string>,
  \"opportunityId\": <string>,
  \"workflowId\": <string>,
  \"workflowVersionId\": <string>,
  \"workflowRunId\": <string>,
  \"taskId\": <string>,
  \"noteId\": <string>,
  \"favoriteFolderId\": <string>,
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
URL="${TWENTY_BASE_URL}/rest/favorites/${ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
