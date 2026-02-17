#!/bin/bash

# Backup script calls the containers backup function and then archives 
# the backup data into the hour's tar ball.
set -xe

USER=$(awk -F':' -v uid=1001 '$3 == uid { print $1 }' /etc/passwd)
BACKUP="/tmp/backup"
CACHE="$BACKUP/cache"
/bin/mkdir -p $CACHE

/bin/chown 1001:1001 $CACHE
cd $CACHE

/bin/su "$USER" -c ". /etc/container/backup ; container_backup"
CONTAINER="$(/bin/hostname | awk -F '-' '{print $1}')"
ARCHIVE="$BACKUP/$(/bin/date +%H)-$CONTAINER.tgz"
/bin/tar  --create --gzip --file="$ARCHIVE" --verbose ./*
/bin/mv -v "$ARCHIVE" /mnt/volumes/backup/
