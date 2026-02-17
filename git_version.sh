#!/usr/bin/env bash
set -eu

# Usage: ./get_version.sh [owner/repo]
# Default repo is gethomepage/homepage
REPO="${1:-gethomepage/homepage}"

API="https://api.github.com/repos/$REPO"
# HDRS="-H \"Accept: application/vnd.github+json\""
# Use a token if available (avoids low rate limits)
[ -n "${GITHUB_TOKEN:-}" ] && HDRS="$HDRS -H Authorization: Bearer $GITHUB_TOKEN"

# 1) Try the "latest release" endpoint (ignores drafts & prereleases)
JSON=$(curl -fsSL -H 'Accept: application/vnd.github+json' "$API/releases/latest") || {
  echo "Error: could not reach GitHub API for $REPO" >&2
  exit 1
}

# 2) Extract tag_name
if command -v jq >/dev/null 2>&1; then
  TAG=$(printf '%s' "$JSON" | jq -r '.tag_name // empty')
else
  # Very small fallback parser for tag_name (works for simple JSON)
  TAG=$(printf '%s' "$JSON" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi

# 3) If latest releases aren't used in this repo, fall back to the newest tag
if [ -z "${TAG:-}" ] || [ "$TAG" = "null" ]; then
  # Fetch tags (first page, which is typically newest first by commit date)
  JSON=$(curl -fsSL -H 'Accept: application/vnd.github+json' "$API/tags?per_page=1") || {
    echo "Error: could not list tags for $REPO" >&2
    exit 1
  }
  if command -v jq >/dev/null 2>&1; then
    TAG=$(printf '%s' "$JSON" | jq -r '.[0].name // empty')
  else
    TAG=$(printf '%s' "$JSON" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
  fi
fi

if [ -z "${TAG:-}" ]; then
  echo "Error: no version tag found for $REPO" >&2
  exit 1
fi

# Print the tag as-is (e.g., v1.2.3). If you want to drop a leading "v", uncomment:
# TAG=${TAG#v}

printf '%s\n' "$TAG"
