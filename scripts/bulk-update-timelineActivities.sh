#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: PATCH /timelineActivities"
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
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/timelineActivities"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
