#!/bin/sh
#
# This is a simple place holder that just prints output to the log to prove
# that the script is being called on a regular basis. Downstream containers
# should overload this script with it's own backup script by over-writting
# /usr/bin/container-backup

echo "BACKUP: default script that does nothing"
