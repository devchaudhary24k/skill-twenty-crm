#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 "
  echo "Endpoint: GET /messageChannelMessageAssociations"
  exit 1
}


# Build the URL
URL="${TWENTY_BASE_URL}/rest/messageChannelMessageAssociations"

# Execute the API call
curl -s -X GET "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  | jq .
