#!/bin/bash
#
# [ENTRYPOINT](https://docs.docker.com/engine/reference/builder/#entrypoint) is the default
# initial process which and executes all the applications and services that run in a container.
#
# This is the default ENTRYPOINT located at `/usr/sbin/entrypoint` and should be 
# augmented when used in downstream containers by over writting the `/etc/container/entrypoint` 
# file (which by default is a symlink to `/mnt/volumes/container/entrypoint`
#

/bin/echo
/bin/echo "~~~~~~~~~~~~~~~~~~~~~~~~"
/bin/echo

# shellcheck disable=SC2124
ENTRYPOINT_PARAMS="$@"

# shellcheck disable=SC1091
# shellcheck disable=SC4036
. /etc/container/entrypoint

# shellcheck disable=SC3028
/bin/echo "[I] Container ($HOSTNAME $(container_version) as [$(/usr/bin/whoami)])"

# /usr/sbin/cron
/usr/bin/pgrep cron > /dev/null
TEST=$?
if [ $TEST -eq 1 ] ; then
 /bin/echo " [I] Launch cron daemon"
 /usr/bin/sudo /usr/sbin/cron
 RTN=$?
 if [ $RTN -ne 0 ] ; then
  /bin/echo "Application (cron) failed to start"
  exit 1
 fi
fi
 
if [ -z "${ENTRYPOINT_PARAMS}" ] ; then
 /bin/echo " [I] Launch blocking application"
 container_entrypoint "$ENTRYPOINT_PARAMS" 
else
 /bin/echo " [I] Launch application as detatched"
 container_entrypoint "$ENTRYPOINT_PARAMS" >> /mnt/volumes/container/_log 2>&1 &
 exec $ENTRYPOINT_PARAMS
fi
