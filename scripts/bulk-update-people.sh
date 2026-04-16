#!/bin/bash

# Configuration
source "$(dirname "$0")/check-env.sh"

usage() {
  echo "Usage: $0 <json_payload>"
  echo "Endpoint: PATCH /people"
  echo "Expected JSON Body:"
  echo "{
  \"name\": {
    \"firstName\": <string>,
    \"lastName\": <string>,
  },
  \"emails\": {
    \"primaryEmail\": <string>,
    \"additionalEmails\": [
      <string>
    ],
  },
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
  \"jobTitle\": <string>,
  \"phones\": {
    \"additionalPhones\": [
      <string>
    ],
    \"primaryPhoneCountryCode\": <string>,
    \"primaryPhoneCallingCode\": <string>,
    \"primaryPhoneNumber\": <string>,
  },
  \"city\": <string>,
  \"avatarUrl\": <string>,
  \"avatarFile\": [
    {
      \"fileId\": <string>,
      \"label\": <string>,
    }
  ],
  \"position\": <number>,
  \"createdBy\": {
    \"source\": <string>,
  },
  \"updatedBy\": {
    \"source\": <string>,
  },
  \"companyId\": <string>,
}"
  exit 1
}

# Check arguments
PAYLOAD=$1
if [[ -z "$PAYLOAD" ]]; then
  usage
fi

# Build the URL
URL="${TWENTY_BASE_URL}/rest/people"

# Execute the API call
curl -s -X PATCH "$URL" \
  -H "Authorization: Bearer $TWENTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq .
