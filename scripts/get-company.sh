#!/bin/bash

# Standardize Twenty CRM environment variables
source "$(dirname "$0")/check-env.sh"

# Usage information
usage() {
  echo "Usage: $0 <company_id>"
  exit 1
}

# Check for company ID
COMPANY_ID=$1
if [[ -z "$COMPANY_ID" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/companies/${COMPANY_ID}"

# Execute the API call
curl -s -X GET "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" | jq .
