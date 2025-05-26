#!/bin/bash
set -euo pipefail

SERVICE_ID="$1"
VERSION="$2"
RESOURCE_ID="$3"
RESOURCE_NAME="$4"
FASTLY_API_KEY="$5"

VERSION=$(echo "$VERSION" | grep -o '[0-9]\+')

echo "[DEBUG] version=$VERSION service_id=$SERVICE_ID" >&2

# Sanity check
if [[ -z "$SERVICE_ID" || -z "$VERSION" || -z "$RESOURCE_ID" || -z "$RESOURCE_NAME" || -z "$FASTLY_API_KEY" ]]; then
  echo "{\"error\": \"Missing required input\"}" >&2
  exit 1
fi

URL="https://api.fastly.com/service/${SERVICE_ID}/version/${VERSION}/resource"

HTTP_RESPONSE=$(mktemp)
HTTP_CODE=$(curl -sS -w "%{http_code}" -o "$HTTP_RESPONSE" \
  -X POST "$URL" \
  -H "Fastly-Key: ${FASTLY_API_KEY}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"${RESOURCE_NAME}\", \"resource_id\": \"${RESOURCE_ID}\"}")

# 409 = already exists → treat as success
if [[ "$HTTP_CODE" == "409" ]]; then
  echo "{
    \"success\": \"Resource link already exists, no changes made\",
    \"http_status\": \"$HTTP_CODE\",
    \"url\": \"$URL\",
    \"resource_name\": \"$RESOURCE_NAME\"
  }" >&2
  echo "{\"name\": \"${RESOURCE_NAME}\"}"
  rm -f "$HTTP_RESPONSE"
  exit 0
fi

if [[ "$HTTP_CODE" != "200" && "$HTTP_CODE" != "201" ]]; then
  ERROR_BODY=$(cat "$HTTP_RESPONSE")
  rm -f "$HTTP_RESPONSE"
  echo "{
    \"error\": \"Failed to create resource link\",
    \"http_code\": \"$HTTP_CODE\",
    \"url\": \"$URL\",
    \"request_body\": {
      \"name\": \"${RESOURCE_NAME}\",
      \"resource_id\": \"${RESOURCE_ID}\"
    },
    \"response\": $ERROR_BODY
  }" >&2
  exit 1
fi

# 200/201: normal creation, extract values
RESOURCE_LINK_ID=$(grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' "$HTTP_RESPONSE" | head -1 | sed 's/.*: *"\([^"]*\)"/\1/')
NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$HTTP_RESPONSE" | head -1 | sed 's/.*: *"\([^"]*\)"/\1/')

rm -f "$HTTP_RESPONSE"

# Final JSON output for Terraform
echo "{\"resource_link_id\": \"${RESOURCE_LINK_ID}\", \"name\": \"${NAME}\"}"
