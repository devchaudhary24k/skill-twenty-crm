#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> <json_payload>"
  echo "Endpoint: PATCH /timelineActivities/{id}"
  echo "Expected JSON Body:"
  echo "{
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"position\": <number>,
  \"createdBy\": {
    \"source\": <string>,
  },
  \"happensAt\": <string>,
  \"name\": <string>,
  \"properties\": {},
  \"linkedRecordCachedName\": <string>,
  \"linkedRecordId\": <string>,
  \"linkedObjectMetadataId\": <string>,
  \"targetCompanyId\": <string>,
  \"targetDashboardId\": <string>,
  \"targetNoteId\": <string>,
  \"targetOpportunityId\": <string>,
  \"targetPersonId\": <string>,
  \"targetTaskId\": <string>,
  \"workspaceMemberId\": <string>,
  \"targetWorkflowId\": <string>,
  \"targetWorkflowVersionId\": <string>,
  \"targetWorkflowRunId\": <string>,
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
URL="${TWENTY_BASE_URL}/rest/timelineActivities/${ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
