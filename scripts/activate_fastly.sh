#!/bin/bash
set -euo pipefail

SERVICE_ID="$1"
VERSION="$2"
FASTLY_API_KEY="$3"

URL="https://api.fastly.com/service/${SERVICE_ID}/version/${VERSION}/activate"

RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
  -H "Fastly-Key: $FASTLY_API_KEY" \
  -H "Accept: application/json" \
  "$URL")

STATUS=$(echo "$RESPONSE" | awk 'END{print}')
BODY=$(echo "$RESPONSE" | awk 'NR>1{print prev} {prev=$0}' ORS='\n')

if [[ "$STATUS" != "200" ]]; then
  echo "{
    \"error\": \"Failed to activate version\",
    \"http_status\": \"$STATUS\",
    \"url\": \"$URL\",
    \"response\": $BODY
  }" >&2
  exit 1
else
  echo "{
    \"success\": \"Version $VERSION activated successfully\",
    \"http_status\": \"$STATUS\",
    \"service_id\": \"$SERVICE_ID\",
    \"url\": \"$URL\"
  }" >&2

  # ✅ This is what Terraform wants
  echo "{\"version\": \"$VERSION\"}"
fi
