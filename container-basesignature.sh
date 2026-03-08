#!/bin/sh
# container-basesignature: fetches the latest short commit SHA from
# the gautada/debian main branch via the GitHub API.
RESP=$(curl -sf "https://api.github.com/repos/gautada/debian/commits/main" 2>/dev/null) || true
if [ -z "$RESP" ]; then
  echo "unknown"
  exit 0
fi
echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['sha'][:7])" 2>/dev/null || echo "unknown"
