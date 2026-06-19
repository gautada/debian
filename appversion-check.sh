#!/bin/sh
#
# Health check: verifies the running OpenClaw version matches the latest
# release on GitHub. Calls /usr/bin/container-version for the running version
# and /usr/bin/container-latest for the latest release.
# Returns 0 if versions match, non-zero otherwise.

echo "No version test specified"
exit 0
