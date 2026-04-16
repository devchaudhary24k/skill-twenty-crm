#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: POST /workspaceMembers/duplicates"
  echo "Expected JSON Body:"
  echo "{
  \"data\": [
    {
      \"position\": <number>,
      \"name\": {
        \"firstName\": <string>,
        \"lastName\": <string>,
      },
      \"colorScheme\": <string>,
      \"locale\": <string>,
      \"avatarUrl\": <string>,
      \"userEmail\": <string>,
      \"calendarStartDay\": <integer>,
      \"userId\": <string>,
      \"timeZone\": <string>,
      \"dateFormat\": <string>,
      \"timeFormat\": <string>,
      \"numberFormat\": <string>,
      \"createdBy\": {
        \"source\": <string>,
      },
      \"updatedBy\": {
        \"source\": <string>,
      },
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
URL="${TWENTY_BASE_URL}/rest/workspaceMembers/duplicates"

# Execute the API call
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
