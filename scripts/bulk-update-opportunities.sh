#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: PATCH /opportunities"
  echo "Expected JSON Body:"
  echo "{
  \"name\": <string>,
  \"amount\": {
    \"amountMicros\": <number>,
    \"currencyCode\": <string>,
  },
  \"closeDate\": <string>,
  \"stage\": <string>,
  \"position\": <number>,
  \"createdBy\": {
    \"source\": <string>,
  },
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"companyId\": <string>,
  \"pointOfContactId\": <string>,
  \"ownerId\": <string>,
}"
  exit 1
}

# Check arguments
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/opportunities"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
