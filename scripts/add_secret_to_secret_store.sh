#!/bin/bash
set -euo pipefail

STORE_ID="$1"
SECRET_NAME="$2"
SECRET_VALUE="$3"
FASTLY_API_KEY="$4"


SECRET_VALUE=$(echo -n "$SECRET_VALUE" | base64 | tr -d '\n')

URL="https://api.fastly.com/resources/stores/secret/${STORE_ID}/secrets"

RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
  -H "Fastly-Key: ${FASTLY_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\":\"${SECRET_NAME}\",\"secret\":\"${SECRET_VALUE}\"}" \
  "$URL")

# Extract response + HTTP code
STATUS=$(echo "$RESPONSE" | awk 'END{print}')
BODY=$(echo "$RESPONSE" | awk 'NR>1{print prev} {prev=$0}' ORS='\n')

if [[ "$STATUS" != "200" && "$STATUS" != "201" ]]; then
  echo "{
    \"error\": \"Failed to add secret\",
    \"http_status\": \"$STATUS\",
    \"url\": \"$URL\",
    \"store_id\": \"$STORE_ID\",
    \"secret_name\": \"$SECRET_NAME\",
    \"response\": $BODY
  }" >&2
  exit 1
else
  echo "{
    \"success\": \"Secret '$SECRET_NAME' added to store '$STORE_ID'\",
    \"http_status\": \"$STATUS\",
    \"store_id\": \"$STORE_ID\",
    \"secret_name\": \"$SECRET_NAME\"
  }" >&2

  echo "{\"name\": \"${SECRET_NAME}\"}"
fi
