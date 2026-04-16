#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> <json_payload>"
  echo "Endpoint: PATCH /workspaceMembers/{id}"
  echo "Expected JSON Body:"
  echo "{
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
URL="${TWENTY_BASE_URL}/rest/workspaceMembers/${ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
