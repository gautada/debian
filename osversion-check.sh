#!/bin/sh
#
# This script checks if the container version matches the latest Debian release.
# It reads /etc/debian_version to get the current version and compares it
# against the latest Debian stable release version fetched via curl.
# Returns 0 if versions match, non-zero otherwise.

# Get current Debian version directly from /etc/debian_version
CURRENT_VERSION=$(cat /etc/debian_version | tr -d '[:space:]')
if [ -z "$CURRENT_VERSION" ]; then
  echo "Failed to read Debian version from /etc/debian_version"
  exit 1
fi

# Get latest Debian stable version from the Release file
LATEST_VERSION=$(curl -sL https://deb.debian.org/debian/dists/stable/Release | grep "^Version:" | awk '{print $2}')
if [ -z "$LATEST_VERSION" ]; then
  echo "Failed to fetch latest Debian release version"
  exit 1
fi

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "Version check passed"
  exit 0
else
  echo "Version check failed: versions do not match"
  exit 1
fi
