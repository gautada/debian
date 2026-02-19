#!/bin/sh
# 
# This is the control script to test container health. This script will call
# all script that are in the drop-in folder `/etc/container/health.d/`. This 
# script would usually not be called directly but through a symlink. The
# symlinks are /usr/bin/container-liveness, /usr/bin/container-readiness, and
# /usr/bin/container-startup.  This script should determine which symlink was
# called and passed to all scripts in /etc/container/health.d. This allows
# for the drop-in scripts to be able perform different functions based on how
# it was called. If container is healthy then all the drop-in scripts returned
# 0.  An unhealthy container would be if one of the drop scripts returned a
# non-zero. This control script should log which drp-in failed but should
# continue running all the drop-ins and return a non-zero to represent
# unhealthy.  Otherwise just return 0 to report positive health.

HEALTHD="/etc/container/health.d"

if [ ! -d "$HEALTHD" ]; then
 echo "Health drop-in directory not found"
 exit 1
fi

# Parse the function from the executed script
FUNC="$(basename "$0" | awk -F '-' '{print $2}')"
echo "Running ${FUNC} check"
# Load the health scriptS for _container_health function
# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

FAILED=0
for script in "$HEALTHD"/*; do
  if [ -x "$script" ]; then
    "$script" "$FUNC"
    RET=$?
    SCRIPT_NAME=$(basename "$script")
    if [ $RET -ne 0 ]; then
      printf "%s [${RED}FAIL${NC}]\n" "$SCRIPT_NAME"
      FAILED=1
    else
      printf "%s [${GREEN} OK ${NC}]\n" "$SCRIPT_NAME"
    fi
  fi
done

if [ $FAILED -ne 0 ]; then
  exit 1
fi

exit 0

