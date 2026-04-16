#!/bin/bash

# Standardize Twenty CRM environment variables
source "$(dirname "$0")/check-env.sh"

# Usage information
usage() {
  echo "Usage: $0 <company_id> '<json_payload>'"
  echo "Example: $0 '123' '{\"name\": \"Updated Company Name\"}'"
  exit 1
}

# Check for company ID and JSON payload
COMPANY_ID=$1
PAYLOAD=$2
if [[ -z "$COMPANY_ID" ]] || [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/companies/${COMPANY_ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq .
