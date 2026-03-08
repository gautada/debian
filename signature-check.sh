#!/bin/sh
# signature-check: health check that compares the container's build signature
# against the latest commit on the gautada/debian main branch.
SIG=$(/usr/bin/container-signature 2>/dev/null | tr -d '[:space:]')
BASESIG=$(/usr/bin/container-basesignature 2>/dev/null | tr -d '[:space:]')
if [ -z "$SIG" ] || [ "$SIG" = "unknown" ]; then
  echo "signature-check: container signature unavailable"
  exit 1
fi
if [ -z "$BASESIG" ] || [ "$BASESIG" = "unknown" ]; then
  echo "signature-check: could not fetch base signature (network issue?)"
  exit 1
fi
if [ "$SIG" = "$BASESIG" ]; then
  printf "signature-check: match (%s)\n" "$SIG"
  exit 0
else
  printf "signature-check: mismatch (container=%s, base=%s)\n" "$SIG" "$BASESIG"
  exit 1
fi
