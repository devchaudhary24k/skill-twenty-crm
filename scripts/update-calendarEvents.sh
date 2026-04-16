#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> <json_payload>"
  echo "Endpoint: PATCH /calendarEvents/{id}"
  echo "Expected JSON Body:"
  echo "{
  \"location\": <string>,
  \"isCanceled\": <boolean>,
  \"isFullDay\": <boolean>,
  \"startsAt\": <string>,
  \"endsAt\": <string>,
  \"externalCreatedAt\": <string>,
  \"externalUpdatedAt\": <string>,
  \"description\": <string>,
  \"createdBy\": {
    \"source\": <string>,
  },
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"position\": <number>,
  \"title\": <string>,
  \"iCalUid\": <string>,
  \"conferenceSolution\": <string>,
  \"conferenceLink\": {
    \"primaryLinkLabel\": <string>,
    \"primaryLinkUrl\": <string>,
    \"secondaryLinks\": [
      {
        \"url\": <string>,
        \"label\": <string>,
      }
    ],
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
URL="${TWENTY_BASE_URL}/rest/calendarEvents/${ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
