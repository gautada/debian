#!/bin/bash

# This script is the control script to test container health. The default behavior is to
# call the `/etc/container/health` script which will load and run all specific scripts in
# `/etc/container/health.d/*.health`. This script also unifies health checks for startup,
# readiness, and liveness.  The default setup has all of the scripts `/usr/bin/container-liveness`,
# `/usr/bin/container-readiness`, and `/usr/bin/container-startup` point to this script
# `/usr/bin/container-health`.  To overide a downstream container should provide a specific
# respective file `/etc/container/[liveness, readiness, and/or startup]` that defines the
# desired behavior

# HEALTH="/etc/container/health"
# if [ ! -f "$HEALTH" ]; then
#  echo "Health function not defined"
#  exit 1
# fi
# 
# # Parse the function from the executed script
# FUNC="$(echo $0 | awk -F '-' '{print $2}')"
# # Load the health script for _container_health function
# . $HEALTH
# case $FUNC in
#  "liveness" | "readiness" | "startup" | "test")
#   _container_health "$FUNC"
#   _container_health "health"
#  ;;
#  "health")
#   _container_health "health"
#  ;;
#  *)
#   echo "Unknown function[$FUNC]"
#   exit 2
#  ;;
# esac

exit 0
