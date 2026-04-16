#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: POST /favorites/duplicates"
  echo "Expected JSON Body:"
  echo "{
  \"data\": [
    {
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
    }
  ],
  \"ids\": [
    <string>
  ],
}"
  exit 1
}

# Check arguments
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/favorites/duplicates"

# Execute the API call
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
