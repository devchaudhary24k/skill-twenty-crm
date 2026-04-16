#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <id> <json_payload>"
  echo "Endpoint: PATCH /companies/{id}"
  echo "Expected JSON Body:"
  echo "{
  \"name\": <string>,
  \"domainName\": {
    \"primaryLinkLabel\": <string>,
    \"primaryLinkUrl\": <string>,
    \"secondaryLinks\": [
      {
        \"url\": <string>,
        \"label\": <string>,
      }
    ],
  },
  \"address\": {
    \"addressStreet1\": <string>,
    \"addressStreet2\": <string>,
    \"addressCity\": <string>,
    \"addressPostcode\": <string>,
    \"addressState\": <string>,
    \"addressCountry\": <string>,
    \"addressLat\": <number>,
    \"addressLng\": <number>,
  },
  \"employees\": <integer>,
  \"linkedinLink\": {
    \"primaryLinkLabel\": <string>,
    \"primaryLinkUrl\": <string>,
    \"secondaryLinks\": [
      {
        \"url\": <string>,
        \"label\": <string>,
      }
    ],
  },
  \"xLink\": {
    \"primaryLinkLabel\": <string>,
    \"primaryLinkUrl\": <string>,
    \"secondaryLinks\": [
      {
        \"url\": <string>,
        \"label\": <string>,
      }
    ],
  },
  \"annualRecurringRevenue\": {
    \"amountMicros\": <number>,
    \"currencyCode\": <string>,
  },
  \"idealCustomerProfile\": <boolean>,
  \"position\": <number>,
  \"createdBy\": {
    \"source\": <string>,
  },
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"accountOwnerId\": <string>,
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
URL="${TWENTY_BASE_URL}/rest/companies/${ID}"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
