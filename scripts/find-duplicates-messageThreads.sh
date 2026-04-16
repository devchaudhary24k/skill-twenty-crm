#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: POST /messageThreads/duplicates"
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
URL="${TWENTY_BASE_URL}/rest/messageThreads/duplicates"

# Execute the API call
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
