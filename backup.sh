#!/bin/bash
#
# backup: This script defines the default backup mechanism function and should be overloaded by downstream controls

container_backup() {
 echo "[ INFO] Current directory($(/bin/pwd))"
 echo "[ WARN] Default container backup function not customized for container"
 date "+%s" > data
 # removed because this could produce too much data
 # /bin/cp -r /mnt/volumes/container/* ./
 return $?
}
