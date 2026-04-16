#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> "
  echo "Endpoint: DELETE /workflowRuns/{id}"
  exit 1
}

# Check arguments
ID=$1
if [[ -z "$ID" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/workflowRuns/${ID}"

# Execute the API call
curl -s -X DELETE "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  | jq .
