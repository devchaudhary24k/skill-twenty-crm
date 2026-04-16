#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: POST /attachments"
  echo "Expected JSON Body:"
  echo "{
  \"name\": <string>,
  \"file\": [
    {
      \"fileId\": <string>,
      \"label\": <string>,
    }
  ],
  \"fullPath\": <string>,
  \"fileCategory\": <string>,
  \"createdBy\": {
    \"source\": <string>,
  },
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"position\": <number>,
  \"targetTaskId\": <string>,
  \"targetNoteId\": <string>,
  \"targetPersonId\": <string>,
  \"targetCompanyId\": <string>,
  \"targetOpportunityId\": <string>,
  \"targetDashboardId\": <string>,
  \"targetWorkflowId\": <string>,
}"
  exit 1
}

# Check arguments
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/attachments"

# Execute the API call
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
