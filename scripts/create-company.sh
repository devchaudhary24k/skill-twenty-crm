#!/bin/bash

# Standardize Twenty CRM environment variables
source "$(dirname "$0")/check-env.sh"

# Usage information
usage() {
  echo "Usage: $0 '<json_payload>'"
  echo "Example: $0 '{\"name\": \"My Company\", \"domainName\": \"mycompany.com\"}'"
  exit 1
}

# Check for JSON payload
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/companies"

# Execute the API call
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq .
