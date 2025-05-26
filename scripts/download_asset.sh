#!/bin/bash
set -euo pipefail

INPUT=$(cat)

DOWNLOAD_URL=$(echo "$INPUT" | grep -o '"url"[[:space:]]*:[[:space:]]*"[^"]*"'  | sed 's/.*: *"\([^"]*\)"/\1/')
OUTPUT_PATH=$(echo "$INPUT" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/')

if [[ -z "$DOWNLOAD_URL" || -z "$OUTPUT_PATH" ]]; then
  echo "{\"error\": \"Missing required fields: url or path\"}"
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

if curl -fsSL "$DOWNLOAD_URL" -o "$OUTPUT_PATH"; then
  echo "{\"path\": \"$OUTPUT_PATH\"}"
else
  echo "{\"error\": \"Failed to download $DOWNLOAD_URL\"}"
  exit 1
fi
