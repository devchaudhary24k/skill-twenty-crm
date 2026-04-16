#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 "
  echo "Endpoint: DELETE /messages"
  exit 1
}


# Build the URL
URL="${TWENTY_BASE_URL}/rest/messages"

# Execute the API call
curl -s -X DELETE "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  | jq .
